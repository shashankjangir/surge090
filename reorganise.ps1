#!/usr/bin/env pwsh
# reorganise.ps1 — SURGE-090 Repository Restructuring Script
# Run from: c:\surge090
# Safe to re-run: uses -Force and checks existence where needed.

$root = "c:\surge090"
$git  = "$root\git"

# ─────────────────────────────────────────────────────────────
# STEP 1: Create target directory tree
# ─────────────────────────────────────────────────────────────
$dirs = @(
    "$root\src",
    "$root\tests",
    "$root\docs",
    "$root\docs\reports",
    "$root\docs\datasheets",
    "$root\docs\presentations",
    "$root\cad",
    "$root\cad\segments",
    "$root\cad\assembly",
    "$root\cad\motor_models",
    "$root\images",
    "$root\images\hardware",
    "$root\images\cad",
    "$root\images\testing"
)
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}
Write-Host "[1/9] Target directories created."

# ─────────────────────────────────────────────────────────────
# STEP 2: src/ Python modules
# ─────────────────────────────────────────────────────────────
$srcFiles = @(
    "kinematics.py", "obstacle_avoidance.py", "robot_config.py",
    "servo_driver.py", "snake_locomotion.py", "torque_controller.py", "utils.py"
)
foreach ($f in $srcFiles) {
    Move-Item -Force -Path "$git\src\$f" -Destination "$root\src\$f"
}
Write-Host "[2/9] src/ modules moved."

# ─────────────────────────────────────────────────────────────
# STEP 3: tests/
# ─────────────────────────────────────────────────────────────
Move-Item -Force -Path "$git\tests\test_dynamixel_ping.py"  -Destination "$root\tests\"
Move-Item -Force -Path "$git\tests\test_motor_feedback.py"  -Destination "$root\tests\"
Write-Host "[3/9] tests/ moved."

# ─────────────────────────────────────────────────────────────
# STEP 4: instruction/ markdown guides → docs/
# ─────────────────────────────────────────────────────────────
Move-Item -Force -Path "$git\instruction\wiring_diagram.md"               -Destination "$root\docs\"
Move-Item -Force -Path "$git\instruction\raspberry_pi_setup_guide.md"     -Destination "$root\docs\"
Move-Item -Force -Path "$git\instruction\parts_and_safety.md"             -Destination "$root\docs\"
Move-Item -Force -Path "$git\instruction\additional_parts_spreadsheet.md" -Destination "$root\docs\"
Write-Host "[4/9] instruction/ docs moved to docs/."

# ─────────────────────────────────────────────────────────────
# STEP 5: git root docs → docs/ and docs/reports/
# ─────────────────────────────────────────────────────────────
Move-Item -Force -Path "$git\SSH_LOGIN_INSTRUCTIONS.md" -Destination "$root\docs\"
Move-Item -Force -Path "$git\hardware_bom.md"           -Destination "$root\docs\reports\"
Move-Item -Force -Path "$git\starter_kit_manual.md"     -Destination "$root\docs\reports\"
Move-Item -Force -Path "$git\Component_flow.png"        -Destination "$root\docs\"

# Preserve the previous README into docs/reports before we overwrite it
Move-Item -Force -Path "$git\README.md"                 -Destination "$root\docs\reports\README_v1.md"
Write-Host "[5/9] git root docs moved."

# ─────────────────────────────────────────────────────────────
# STEP 6: 3d_parts/ → cad/
# ─────────────────────────────────────────────────────────────
Move-Item -Force -Path "$git\3d_parts\segment1.SLDPRT"  -Destination "$root\cad\segments\"
Move-Item -Force -Path "$git\3d_parts\segment1.STEP"    -Destination "$root\cad\segments\"
Move-Item -Force -Path "$git\3d_parts\segment1_v1.STL"  -Destination "$root\cad\segments\"
Move-Item -Force -Path "$git\3d_parts\segement2.SLDPRT" -Destination "$root\cad\segments\"
Move-Item -Force -Path "$git\3d_parts\segement2.STEP"   -Destination "$root\cad\segments\"
Move-Item -Force -Path "$git\3d_parts\segement2_v1.STL" -Destination "$root\cad\segments\"
Move-Item -Force -Path "$git\3d_parts\assembly.SLDASM"  -Destination "$root\cad\assembly\"
Move-Item -Force -Path "$git\3d_parts\XL,XC-330.stp"   -Destination "$root\cad\motor_models\"
Write-Host "[6/9] 3d_parts/ CAD files moved."

# ─────────────────────────────────────────────────────────────
# STEP 7: git root Python / config files → repo root
# ─────────────────────────────────────────────────────────────
Move-Item -Force -Path "$git\main.py"                 -Destination "$root\"
Move-Item -Force -Path "$git\servo_test.py"           -Destination "$root\"
Move-Item -Force -Path "$git\requirements.txt"        -Destination "$root\"
Move-Item -Force -Path "$git\install_requirements.cmd"-Destination "$root\"
Write-Host "[7/9] Python / config files moved to repo root."

# ─────────────────────────────────────────────────────────────
# STEP 8: Loose root files → organised subdirectories
# ─────────────────────────────────────────────────────────────

# CAD models
Move-Item -Force -Path "$root\XL,XC-330.SLDASM"    -Destination "$root\cad\motor_models\"
Move-Item -Force -Path "$root\XL,XC-330.stp"       -Destination "$root\cad\motor_models\"
Move-Item -Force -Path "$root\assembly.SLDASM"      -Destination "$root\cad\assembly\"
Move-Item -Force -Path "$root\segment1 (2).SLDPRT" -Destination "$root\cad\segments\"
Move-Item -Force -Path "$root\segement2.STEP"       -Destination "$root\cad\segments\"

# Datasheets / reference docs
Move-Item -Force -Path "$root\XL,XC-330.pdf"                       -Destination "$root\docs\datasheets\"
Move-Item -Force -Path "$root\DYNAMIXEL_XL330_1__52682.png"        -Destination "$root\docs\datasheets\"
Move-Item -Force -Path "$root\Raspberry-Pi-5-Pinout-.jpg"          -Destination "$root\docs\datasheets\"

# Presentations
Move-Item -Force -Path "$root\Smart_Snake_Robot_SURGE090_Progress_Review  -  Repaired.pptx" `
                       -Destination "$root\docs\presentations\"

# Hardware product images
Move-Item -Force -Path "$root\dynamixel.webp" -Destination "$root\images\hardware\"
Move-Item -Force -Path "$root\motor.png"      -Destination "$root\images\hardware\"
Move-Item -Force -Path "$root\Picture1.jpg"   -Destination "$root\images\hardware\"
Move-Item -Force -Path "$root\servo.jpg"      -Destination "$root\images\hardware\"
Move-Item -Force -Path "$root\list 2.jpeg"    -Destination "$root\images\hardware\"

# CAD renders / screenshots
Move-Item -Force -Path "$root\segment 1.png"              -Destination "$root\images\cad\"
Move-Item -Force -Path "$root\segment 1 view 2.png"       -Destination "$root\images\cad\"
Move-Item -Force -Path "$root\segment 1 real.jpeg"        -Destination "$root\images\cad\"
Move-Item -Force -Path "$root\segment 1 view 2 real.jpeg" -Destination "$root\images\cad\"

# Testing photos + video
Move-Item -Force -Path "$root\WhatsApp Image 2026-05-29 at 4.32.34 PM.jpeg" -Destination "$root\images\testing\"
Move-Item -Force -Path "$root\running raspberry pi.jpeg"  -Destination "$root\images\testing\"
Move-Item -Force -Path "$root\terminal of rasp.jpeg"      -Destination "$root\images\testing\"
Move-Item -Force -Path "$root\terminal of rasp 2.jpeg"    -Destination "$root\images\testing\"
Move-Item -Force -Path "$root\testing video.mp4"          -Destination "$root\images\testing\"
Write-Host "[8/9] Root loose files organised."

# ─────────────────────────────────────────────────────────────
# STEP 9: Remove empty git/ subdirectories (no files deleted)
# ─────────────────────────────────────────────────────────────
Remove-Item -Recurse -Force "$git\src"         -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$git\tests"       -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$git\3d_parts"    -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$git\instruction" -ErrorAction SilentlyContinue
# Remove git/ itself only if now empty
$remaining = Get-ChildItem "$git" -ErrorAction SilentlyContinue
if (-not $remaining) {
    Remove-Item -Force "$git" -ErrorAction SilentlyContinue
    Write-Host "[9/9] git/ subdirectory removed (was empty)."
} else {
    Write-Host "[9/9] git/ subdirectory kept (contains remaining items):"
    $remaining | ForEach-Object { Write-Host "      $_" }
}

Write-Host ""
Write-Host "========================================"
Write-Host " Reorganisation complete!"
Write-Host "========================================"
