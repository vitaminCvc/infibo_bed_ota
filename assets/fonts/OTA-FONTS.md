# OTA language fonts

These open fonts supply glyphs missing from MicrosoftYaHei-Regular.ttf in the system update page, confirmations and progress UI. Existing Latin/Cyrillic/Chinese rendering keeps its primary font.

- NotoSansArabic-Variable.ttf: unmodified variable font from Google Fonts, https://github.com/google/fonts/tree/main/ofl/notosansarabic . License: NotoSansArabic-OFL.txt (also bundled in APK assets).
- InfiboOtaKorean-Regular.ttf: derived from NotoSansKR[wght].ttf at https://github.com/google/fonts/tree/main/ofl/notosanskr . Instantiated at weight 400, retaining full Hangul syllables/Jamo, basic Latin and general punctuation; CJK ideographs remain covered by the primary font. Renamed internally to Infibo OTA Korean. License: NotoSansKR-OFL.txt (also bundled).

The Korean derivative was made with fontTools.varLib.instancer at wght=400 and fontTools.subset with U+0020-007E, U+1100-11FF, U+2000-206F, U+3130-318F, U+A960-A97F and U+AC00-D7FF. This reduces the source's 10.4 MB variable font to a 2.75 MB static Hangul font without limiting Korean text to the current UI strings. Both fonts remain distributed under SIL OFL 1.1.
