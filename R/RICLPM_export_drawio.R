export_drawio <- function(
  fit,
  output_file = "RICLPM_model.drawio",
  standardized = TRUE,
  p_thresholds = c(0.05, 0.01, 0.001),
  node_distance_x = 300,
  node_distance_y = 120,
  base_x = 150,
  base_y = 300,
  node_width = 80,
  node_height = 40,
  node_shape = "rectangle",
  font_size = 12
) {
  required_packages <- c("lavaan", "dplyr", "glue", "stringr", "tibble")
  missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

  if (length(missing_packages) > 0) {
    install.packages(missing_packages, dependencies = TRUE)
  }

  still_missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]

  if (length(still_missing) > 0) {
    stop(
      paste(
        "The following packages could not be installed or loaded:",
        paste(still_missing, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  suppressPackageStartupMessages({
    library(lavaan)
    library(dplyr)
    library(glue)
    library(stringr)
    library(tibble)
  })

  est_data <- lavaan::parameterEstimates(fit, standardized = standardized)

  if (!"group" %in% names(est_data)) {
    est_data$group <- 1
  }

  pop_groups <- unique(est_data$group)

  group_names <- lavaan::lavInspect(fit, "group.label")
  if (length(group_names) == 0) {
    group_names <- "Model"
  }

  est_structure <- est_data %>% dplyr::filter(group == pop_groups[1])

  ov_vars <- lavaan::lavNames(fit, "ov")
  lv_vars <- lavaan::lavNames(fit, "lv")

  by_paths <- est_structure %>% dplyr::filter(op == "=~")
  on_paths_all <- est_structure %>% dplyr::filter(op == "~" & rhs != "1" & lhs != "1")

  lv_on_paths <- on_paths_all %>% dplyr::filter(lhs %in% lv_vars & rhs %in% lv_vars)

  within_vars <- unique(c(lv_on_paths$lhs, lv_on_paths$rhs))

  ri_vars <- lv_vars[
    (lv_vars %in% by_paths$lhs) &
      !(lv_vars %in% by_paths$rhs) &
      !(lv_vars %in% within_vars)
  ]

  factor_vars <- setdiff(lv_vars, c(ri_vars, within_vars))
  has_factor <- length(factor_vars) > 0

  all_panel_vars <- unique(c(ri_vars, within_vars, factor_vars, by_paths$rhs))

  get_components <- function(edges) {
    if (nrow(edges) == 0) {
      return(tibble::tibble(var_name = character(), group_id = numeric()))
    }

    nodes <- unique(c(edges$lhs, edges$rhs))
    comp <- stats::setNames(seq_along(nodes), nodes)

    for (i in seq_len(nrow(edges))) {
      c1 <- comp[edges$lhs[i]]
      c2 <- comp[edges$rhs[i]]

      if (c1 != c2) {
        comp[comp == c2] <- c1
      }
    }

    comp_id <- as.numeric(as.factor(comp))
    tibble::tibble(var_name = names(comp), group_id = comp_id)
  }

  group_map <- get_components(by_paths %>% dplyr::select(lhs, rhs))
  n_var_sets <- length(unique(group_map$group_id))

  within_on_paths <- on_paths_all %>% dplyr::filter(lhs %in% within_vars & rhs %in% within_vars)
  wave_map <- tibble::tibble(var_name = character(), wave_idx = numeric())

  if (nrow(within_on_paths) > 0) {
    all_rhs <- unique(within_on_paths$rhs)
    all_lhs <- unique(within_on_paths$lhs)
    current_nodes <- setdiff(all_rhs, all_lhs)

    if (length(current_nodes) == 0) {
      current_nodes <- all_rhs
    }

    current_wave <- 1

    while (length(current_nodes) > 0) {
      wave_map <- dplyr::bind_rows(
        wave_map,
        tibble::tibble(var_name = current_nodes, wave_idx = current_wave)
      )

      next_nodes <- within_on_paths %>%
        dplyr::filter(rhs %in% current_nodes) %>%
        dplyr::pull(lhs) %>%
        unique()

      next_nodes <- setdiff(next_nodes, wave_map$var_name)
      current_nodes <- next_nodes
      current_wave <- current_wave + 1
    }
  }

  current_wave_nodes <- wave_map

  while (nrow(current_wave_nodes) > 0) {
    next_step <- by_paths %>%
      dplyr::inner_join(current_wave_nodes, by = c("lhs" = "var_name")) %>%
      dplyr::select(var_name = rhs, wave_idx) %>%
      dplyr::filter(!var_name %in% wave_map$var_name) %>%
      dplyr::distinct()

    if (nrow(next_step) == 0) {
      break
    }

    wave_map <- dplyr::bind_rows(wave_map, next_step)
    current_wave_nodes <- next_step
  }

  edges_raw <- est_data %>%
    dplyr::filter(op %in% c("~", "~~", "=~")) %>%
    dplyr::filter(rhs != "1" & lhs != "1") %>%
    dplyr::mutate(
      sig_stars = dplyr::case_when(
        pvalue < p_thresholds[3] ~ "***",
        pvalue < p_thresholds[2] ~ "**",
        pvalue < p_thresholds[1] ~ "*",
        TRUE ~ ""
      ),
      coef_val = if (standardized) std.all else est,
      label_text = ifelse(is.na(coef_val), "", paste0(sprintf("%.2f", coef_val), sig_stars))
    )

  all_vars <- unique(c(edges_raw$lhs, edges_raw$rhs))
  all_vars <- all_vars[all_vars != ""]

  diagram_height <- ifelse(
    n_var_sets == 2,
    node_distance_y * 10,
    (n_var_sets * 5 + 2) * node_distance_y
  )

  max_wave <- suppressWarnings(max(wave_map$wave_idx, na.rm = TRUE))
  if (is.infinite(max_wave)) {
    max_wave <- 5
  }

  ext_vars <- setdiff(all_vars, all_panel_vars)

  time_varying_preds <- unique(c(within_vars, factor_vars, ov_vars))

  vars_influenced_by_tv <- on_paths_all %>%
    dplyr::filter(rhs %in% time_varying_preds) %>%
    dplyr::pull(lhs) %>%
    unique()

  nodes_df <- expand.grid(var_name = all_vars, pop_group = pop_groups, stringsAsFactors = FALSE) %>%
    tibble::as_tibble() %>%
    dplyr::mutate(
      node_id = dplyr::row_number() + 100,
      is_ov = var_name %in% ov_vars,
      is_lv = var_name %in% lv_vars,
      is_ri = var_name %in% ri_vars,
      is_within = var_name %in% within_vars,
      is_factor = var_name %in% factor_vars,
      is_external = !(var_name %in% all_panel_vars),
      is_ext_pred = is_external & (var_name %in% on_paths_all$rhs),
      is_ext_out = is_external & (var_name %in% on_paths_all$lhs) & !is_ext_pred,
      ext_idx = match(var_name, ext_vars),
      influenced_by_tv = var_name %in% vars_influenced_by_tv
    ) %>%
    dplyr::left_join(group_map, by = "var_name") %>%
    dplyr::mutate(group_id = ifelse(is.na(group_id), 1, group_id)) %>%
    dplyr::left_join(wave_map, by = "var_name") %>%
    dplyr::mutate(
      fallback_num = as.numeric(stringr::str_extract(var_name, "\\d+$")),
      fallback_num = ifelse(is.na(fallback_num), 1, fallback_num),
      calc_wave = dplyr::case_when(
        is_ext_pred ~ -1,
        is_ext_out & !influenced_by_tv ~ 0,
        is_ext_out ~ max_wave + 1.5,
        is_ri ~ ifelse(is.na(as.numeric(stringr::str_extract(var_name, "\\d+$"))), 0, fallback_num),
        !is.na(wave_idx) ~ wave_idx,
        TRUE ~ fallback_num
      )
    ) %>%
    dplyr::group_by(pop_group, group_id, calc_wave, is_ri, is_within, is_factor, is_ov) %>%
    dplyr::mutate(
      n_in_group = dplyr::n(),
      sub_idx = dplyr::row_number() - 1,
      offset_x = ifelse(is_ov, (sub_idx - (n_in_group - 1) / 2) * (node_width * 1.2), 0)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      coord_x = base_x + calc_wave * node_distance_x + offset_x,
      base_coord_y = dplyr::case_when(
        is_external ~ base_y + node_distance_y * 1.5 + ifelse(!is.na(ext_idx), (ext_idx - 1) * 80, 0),
        n_var_sets == 2 ~ dplyr::case_when(
          group_id == 1 & is_ri ~ base_y - node_distance_y * 3.5 + (sub_idx * node_distance_y * 0.6),
          group_id == 1 & is_ov ~ base_y - node_distance_y * ifelse(has_factor, 2.75, 2.0),
          group_id == 1 & is_factor ~ base_y - node_distance_y * 2.0,
          group_id == 1 & is_within ~ base_y - node_distance_y * 0.5 + (sub_idx * node_distance_y * 0.6),
          group_id == 2 & is_within ~ base_y + node_distance_y * 0.5 + (sub_idx * node_distance_y * 0.6),
          group_id == 2 & is_factor ~ base_y + node_distance_y * 2.0,
          group_id == 2 & is_ov ~ base_y + node_distance_y * ifelse(has_factor, 2.75, 2.0),
          group_id == 2 & is_ri ~ base_y + node_distance_y * 3.5 + (sub_idx * node_distance_y * 0.6),
          TRUE ~ base_y
        ),
        TRUE ~ dplyr::case_when(
          is_ri ~ base_y + (group_id - 1) * (node_distance_y * 5) - node_distance_y * 1.5 + (sub_idx * node_distance_y * 0.6),
          is_ov ~ base_y + (group_id - 1) * (node_distance_y * 5) - node_distance_y * ifelse(has_factor, 0.75, 0),
          is_factor ~ base_y + (group_id - 1) * (node_distance_y * 5),
          is_within ~ base_y + (group_id - 1) * (node_distance_y * 5) + node_distance_y * 1.5 + (sub_idx * node_distance_y * 0.6),
          TRUE ~ base_y
        )
      ),
      coord_y = base_coord_y + (pop_group - 1) * diagram_height,
      shape = ifelse(is_lv, "ellipse", node_shape)
    )

  xml_base_start <- '<mxGraphModel dx="1000" dy="1000" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="827" pageHeight="1169" math="0" shadow="0">\n  <root>\n    <mxCell id="0" />\n    <mxCell id="1" parent="0" />'
  xml_base_end <- '  </root>\n</mxGraphModel>'

  nodes_xml <- nodes_df %>%
    glue::glue_data(
      '    <mxCell id="{node_id}" value="{var_name}" style="shape={shape};whiteSpace=wrap;html=1;fontSize={font_size};fillColor=#FFFFFF;strokeColor=#000000;" vertex="1" parent="1">',
      '      <mxGeometry x="{coord_x}" y="{coord_y}" width="{node_width}" height="{node_height}" as="geometry" />',
      '    </mxCell>'
    ) %>%
    paste(collapse = "\n")

  labels_xml <- tibble::tibble(pop_group = pop_groups) %>%
    dplyr::mutate(
      label_id = dplyr::row_number() + 10,
      coord_x = base_x + 50,
      coord_y = base_y + (pop_group - 1) * diagram_height - node_distance_y * 4.5,
      lbl_text = sapply(pop_group, function(g) {
        if (length(group_names) >= g && nchar(group_names[g]) > 0) {
          return(group_names[g])
        }
        return(paste("Group", g))
      })
    ) %>%
    glue::glue_data(
      '    <mxCell id="lbl_{label_id}" value="{lbl_text}" style="text;html=1;strokeColor=none;fillColor=none;align=left;verticalAlign=middle;whiteSpace=wrap;rounded=0;fontSize={font_size + 4};fontStyle=1" vertex="1" parent="1">',
      '      <mxGeometry x="{coord_x}" y="{coord_y}" width="300" height="40" as="geometry" />',
      '    </mxCell>'
    ) %>%
    paste(collapse = "\n")

  max_node_id <- max(nodes_df$node_id)

  edges_df <- edges_raw %>%
    dplyr::left_join(
      nodes_df %>% dplyr::select(var_name, pop_group, source_id = node_id, s_is_ri = is_ri, s_x = coord_x, s_y = coord_y),
      by = c("rhs" = "var_name", "group" = "pop_group")
    ) %>%
    dplyr::left_join(
      nodes_df %>% dplyr::select(var_name, pop_group, target_id = node_id, t_is_ri = is_ri, t_x = coord_x, t_y = coord_y),
      by = c("lhs" = "var_name", "group" = "pop_group")
    ) %>%
    dplyr::mutate(
      edge_id = dplyr::row_number() + max_node_id + 100,
      actual_source = ifelse(op == "=~", target_id, source_id),
      actual_target = ifelse(op == "=~", source_id, target_id),
      is_ri_cov = (op == "~~" & dplyr::coalesce(s_is_ri, FALSE) & dplyr::coalesce(t_is_ri, FALSE))
    ) %>%
    dplyr::group_by(is_ri_cov) %>%
    dplyr::mutate(
      wp_x = ifelse(is_ri_cov, base_x - 80 - (dplyr::row_number() * 25), NA_real_),
      wp_y = ifelse(is_ri_cov, (s_y + t_y) / 2, NA_real_)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      edge_style = dplyr::case_when(
        is_ri_cov ~ "endArrow=classic;startArrow=classic;html=1;curved=1;exitX=0;exitY=0.5;entryX=0;entryY=0.5;",
        op == "~~" ~ "endArrow=classic;startArrow=classic;html=1;curved=1;edgeStyle=orthogonalEdgeStyle;",
        TRUE ~ "endArrow=classic;html=1;rounded=0;"
      ),
      geometry_xml = dplyr::case_when(
        is_ri_cov ~ glue::glue('<mxGeometry relative="1" as="geometry"><Array as="points"><mxPoint x="{wp_x}" y="{wp_y}" /></Array></mxGeometry>'),
        TRUE ~ '<mxGeometry relative="1" as="geometry" />'
      )
    )

  edges_xml <- edges_df %>%
    glue::glue_data(
      '    <mxCell id="{edge_id}" value="{label_text}" style="{edge_style}fontSize={font_size};" edge="1" parent="1" source="{actual_source}" target="{actual_target}">',
      '      {geometry_xml}',
      '    </mxCell>'
    ) %>%
    paste(collapse = "\n")

  final_xml <- paste(xml_base_start, labels_xml, nodes_xml, edges_xml, xml_base_end, sep = "\n")

  if (!stringr::str_ends(output_file, "(?i)\\.drawio$")) {
    output_file <- paste0(output_file, ".drawio")
  }

  writeLines(final_xml, con = output_file, useBytes = TRUE)
  full_path <- normalizePath(output_file, mustWork = FALSE)

  message("--------------------------------------------------")
  message(glue::glue("Export completed successfully."))
  message(glue::glue("File: {full_path}"))
  message("Please open this file in draw.io or diagrams.net.")
  message("--------------------------------------------------")

  invisible(final_xml)
}