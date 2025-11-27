corpus <- file.path("data", "20251117-homo-calculans-corpus.csv") |>
  readr::read_csv() |> 
  dplyr::select(
    id = Key,
    type = `Item Type`,
    year = `Publication Year`,
    author = Author,
    title = Title,
    collection = `Publication Title`,
    tags = `Manual Tags`,
    pdf = `File Attachments`
  ) |> 
  dplyr::mutate(
    text = purrr::map(pdf, pdftools::pdf_text)
  ) |> 
  dplyr::mutate(
    text = purrr::map_chr(text, \(t) paste0(t, collapse = " "))
  )

corpus_tags <- corpus |> 
  # Split tags
  dplyr::mutate(
    tags = stringr::str_split(tags, ";")
  ) |> 
  tidyr::unnest(tags) |> 
  dplyr::mutate(
    tags = stringr::str_trim(tags),
    tags = stringr::str_split_fixed(tags, ": ", 2),
    tag_type = tags[,1],
    tag = tags[,2]
  ) |> 
  dplyr::select(-tags) |> 
  dplyr::filter(
    tag_type %in% c("Discipline", "Computer", "Program", "Programming Language")
  )

corpus_words <- corpus |> 
  tidytext::unnest_tokens(word, text)