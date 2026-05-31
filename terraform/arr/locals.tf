# Custom formats partagés Radarr/Sonarr (ReleaseTitleSpecification, '\b' -> '\\b').
# Langue FR favorisée, VOSTFR/VFQ + unwanted bloqués (-10000). HDR/DV : bonus
# faibles (<50) pour ne pas faire passer une release non-FR sous min_format_score.
# `score` = 2 profils ; `score_1080p`/`score_2160p` surchargent par résolution.
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

    br_disk = {
      name  = "BR-DISK"
      score = -10000
      specifications = [{
        name           = "BR-DISK"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(BR.?DISK|COMPLETE.?(UHD.?)?BLU.?RAY|BD(25|50|66|100)|BDMV)\\b"
      }]
    }

    threed = {
      name  = "3D"
      score = -10000
      specifications = [{
        name           = "3D"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(3D|HSBS|H-SBS|HalfSBS|HOU|H-OU|HalfOU)\\b"
      }]
    }

    upscaled = {
      name  = "Upscaled"
      score = -10000
      specifications = [{
        name           = "Upscaled"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(upscale[ds]?|AI.?upscale)\\b"
      }]
    }

    # x265/HEVC : indésirable en 1080p (réencodage), normal en 2160p.
    x265_hd = {
      name        = "x265 (HD)"
      score       = 0
      score_1080p = -10000
      specifications = [{
        name           = "x265 (HD)"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b((x|h)\\.?265|HEVC)\\b"
      }]
    }

    hdr = {
      name  = "HDR"
      score = 15
      specifications = [{
        name           = "HDR"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(HDR|PQ|HLG)\\b"
      }]
    }

    hdr10plus = {
      name  = "HDR10+"
      score = 8
      specifications = [{
        name           = "HDR10+"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(HDR10\\+|HDR10P|HDR10PLUS)\\b"
      }]
    }

    dolby_vision = {
      name  = "Dolby Vision"
      score = 20
      specifications = [{
        name           = "Dolby Vision"
        implementation = "ReleaseTitleSpecification"
        negate         = false
        required       = true
        value          = "\\b(DV|DOVI|DOLBY.?VISION)\\b"
      }]
    }
  }
}
