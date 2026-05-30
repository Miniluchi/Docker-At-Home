# Custom formats FR partagés Radarr/Sonarr (mêmes regex, mêmes scores).
# Favorise FRENCH/MULTi/TRUEFRENCH (scores +) ; bloque VOSTFR/VFQ (-10000, sous
# le min_format_score des profils). Match sur le titre de release
# (ReleaseTitleSpecification) : seul moyen fiable de distinguer les variantes FR.
# En HCL, '\b' s'écrit '\\b'.
locals {
  custom_formats = {
    multi = {
      name  = "MULTi"
      score = 100
      specifications = [{
        name           = "MULTi"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bMULTi\\b"
      }]
    }

    truefrench = {
      name  = "TRUEFRENCH"
      score = 75
      specifications = [{
        name           = "TRUEFRENCH"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bTRUEFRENCH\\b"
      }]
    }

    french = {
      name  = "FRENCH"
      score = 50
      specifications = [{
        name           = "FRENCH"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bFRENCH\\b"
      }]
    }

    repack_proper = {
      name  = "Repack/Proper"
      score = 5
      specifications = [{
        name           = "Repack/Proper/Rerip"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(REPACK|PROPER|RERIP)\\b"
      }]
    }

    vostfr = {
      name  = "VOSTFR"
      score = -10000
      specifications = [{
        name           = "VOSTFR / SUBFRENCH"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(VOSTFR|SUBFRENCH|SUBFR)\\b"
      }]
    }

    vfq = {
      name  = "VFQ"
      score = -10000
      specifications = [{
        name           = "VFQ (doublage québécois)"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\bVFQ\\b"
      }]
    }
  }
}
