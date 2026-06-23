        # SURGE-090 · Smart Snake Robot

        **SURGE Summer Research Programme · Indian Institute of Technology Delhi**

        ---

        ## Abstract

        SURGE-090 is a ten-degree-of-freedom, bio-inspired snake robot designed for locomotion in unstructured and confined environments. The platform employs sinusoidal lateral undulation to propel itself forward and uses proprioceptive motor-current sensing as a tactile collision detector — eliminating the need for any external proximity or force sensors. The control architecture is implemented entirely in Python running on a Raspberry Pi, communicating with ROBOTIS Dynamixel XL330 smart servo actuators over a TTL serial daisy chain.

        The project was developed as part of the **SURGE (Summer Undergraduate Research Grant for Excellence)** programme at **IIT Delhi**.

        ---

        ## Table of Contents

        1. [Features](#features)
        2. [System Architecture](#system-architecture)
        3. [Repository Structure](#repository-structure)
        4. [Hardware Requirements](#hardware-requirements)
        5. [Software Setup](#software-setup)
        6. [Running the Robot](#running-the-robot)
        7. [Module Reference](#module-reference)
        8. [CAD Files](#cad-files)
        9. [Documentation](#documentation)
        10. [Team](#team)

        ---

        ## Features

        | Feature | Description |
        |---|---|
        | **10-DOF Serpentine Gait** | Sinusoidal lateral undulation via a travelling sine wave propagated across all joints |
        | **Sensorless Obstacle Detection** | Motor current monitored at 50 Hz; stall current spike (> 350 mA) triggers evasion |
        | **Autonomous Evasion** | State machine: reverse (2.5 s) → side-aware turn (4 s) → resume forward |
        | **Side-Aware Turning** | Sign of the stalling motor's current determines which way the robot evades |
        | **Tethered & Untethered Modes** | Works via USB from a laptop or fully autonomous on on-board Raspberry Pi |
        | **3D-Printed Body** | All structural segments designed in SolidWorks; STEP and STL files provided |

        ---

        ## System Architecture

        ```
        ┌────────────────────────────────────────────┐
        │              Raspberry Pi 5                │
        │                                            │
        │  main.py  ──── Control Loop @ 50 Hz        │
        │     │                                      │
        │     ├──► src/obstacle_avoidance.py         │
        │     │        Current-based state machine   │
        │     │        SLITHER → REV → TURN → ...    │
        │     │                                      │
        │     ├──► src/snake_locomotion.py           │
        │     │        Sinusoidal gait generator     │
        │     │        turn_direction from avoidance │
        │     │                                      │
        │     └──► Dynamixel SDK                     │
        │               write4ByteTxRx (positions)   │
        │               read2ByteTxRx  (current)     │
        └──────────────┬─────────────────────────────┘
                │ USB  ←→  ROBOTIS U2D2
                ┌──────┴──────┐
                │  U2D2 + PHB  │  (power injection at 5V)
                └──────┬───────┘
                │ X3P TTL cables — daisy chain
        ┌───────────▼──────────────────────────────┐
        │  Motor 1 → Motor 2 → … → Motor 10        │
        │       ROBOTIS Dynamixel XL330-M288-T      │
        └───────────────────────────────────────────┘
        ```

        **Obstacle Evasion State Machine**

        ```
        SLITHER ──(|I| > 350 mA)──► SLITHER_REV (2.5 s)
                                        │
                                (timer expires)
                                        ▼
                                SLITHER_TURN (4.0 s)
                                        │
                                (timer expires)
                                        ▼
                                SLITHER
        ```

        ---

        ## Repository Structure

        ```
        surge090/
        ├── main.py                          # Entry point — 50 Hz control loop
        ├── servo_test.py                    # ⚠ DEPRECATED — SG90 GPIO prototype only
        ├── requirements.txt                 # Python dependencies
        ├── install_requirements.cmd         # Windows one-click installer
        ├── reorganise.ps1                   # Repo restructuring utility (run once)
        │
        ├── src/                             # Core robot software
        │   ├── __init__.py
        │   ├── robot_config.py              # All hardware constants & tuning parameters
        │   ├── utils.py                     # Shared utilities (current sign conversion)
        │   ├── snake_locomotion.py          # Sinusoidal gait engine
        │   ├── obstacle_avoidance.py        # Collision state machine
        │   ├── kinematics.py                # Bellows-model joint angle calculator
        │   ├── servo_driver.py              # HAL — mock + Dynamixel SDK interface
        │   └── torque_controller.py         # PD torque controller with compliance
        │
        ├── tests/                           # Hardware validation scripts
        │   ├── test_dynamixel_ping.py       # Ping all motors; report missing IDs
        │   └── test_motor_feedback.py       # Live position / velocity / current readout
        │
        ├── CAD/                             # 3D mechanical models
        │   ├── Segment_v1.stl               # Main segment body STL
        │   ├── Segment_v2.stl               # Secondary segment body STL
        │   └── Assembly.step                # Full robot 3D assembly STEP
        │
        ├── Documentation/                   # Project reports & presentations
        │   ├── Progress_Report_25_Percent.pdf # Initial project milestone review
        │   └── Presentation.pptx            # Presentation slides for reviews
        │
        ├── Simulation/                      # Wokwi simulated sensor node
        │   └── Wokwi/
        │       ├── diagram.json
        │       ├── sketch.ino
        │       ├── libraries.txt
        │       └── README.md
        │
        ├── Images/                          # CAD model renders and physical photos
        │   ├── CAD_Model.png
        │   ├── Printed_Segment_1.jpg
        │   ├── Printed_Segment_2.jpg
        │   └── Simulation_Architecture.png
        │
        └── Hardware/                        # Actuator details and pricing
            ├── BOM.xlsx                     # Interactive Excel sheet for budget
            └── Dynamixel_Selection.md       # Rationale for choosing Dynamixel XL330
        ```

        ---

        ## Hardware Requirements

        | Component | Qty | Approx. Cost (INR) | Notes |
        |---|:---:|---:|---|
        | Dynamixel XL330-M288-T | 10 + 2 spares | ₹36,000 | Core joints; 0.52 Nm @ 5V |
        | ROBOTIS U2D2 (USB-TTL) | 1 | ₹4,500 | Serial bridge to motors |
        | U2D2 Power Hub Board (PHB) | 1 | ₹1,500 | 5V power injection into bus |
        | Raspberry Pi 4 / 5 (4 GB) | 1 | ₹5,500 | On-board compute (optional for tethered) |
        | 5V / 10–20A SMPS *(tethered)* | 1 | ₹2,000 | Mean Well LRS-100-5 recommended |
        | *or* 2S LiPo + 5V UBEC *(untethered)* | 1 | ₹3,500 | Portable power option |
        | Dynamixel X3P Cables (×10) | 1 pack | ₹1,500 | Daisy-chain data + power |
        | F623ZZ Flange Bearings | 10 | ₹1,000 | Load relief for servo horns |
        | Braided Expandable Sleeving | 1 m | ₹2,000 | Robot "skin" — provides traction |
        | M2 / M2.5 Machine Screws | 1 kit | ₹500 | Mount 3D-printed brackets to motors |
        | **Total** | | **≈ ₹52,500** | Out of ₹1,00,000 budget |

        > Full specifications: [`Hardware/BOM.xlsx`](Hardware/BOM.xlsx)

        ---

        ## Software Setup

        ### Prerequisites

        - Python 3.8+
        - ROBOTIS U2D2 connected via USB

        ### 1. Clone

        ```bash
        git clone https://github.com/<org>/surge090.git
        cd surge090
        ```

        ### 2. Install Dependencies

        **Windows (one-click):**
        ```cmd
        install_requirements.cmd
        ```

        **Any platform:**
        ```bash
        pip install -r requirements.txt
        ```

        > Dependencies: `dynamixel-sdk >= 4.0.5`, `pyserial >= 3.5`

        ### 3. Set COM Port

        Open [`main.py`](main.py) and confirm the serial port for your system:

        ```python
        # Windows
        DEVICENAME = 'COM3'

        # Linux / Raspberry Pi
        DEVICENAME = '/dev/ttyUSB0'
        ```

        Find the correct port in **Device Manager** (Windows) or `ls /dev/ttyUSB*` (Linux).

        ### 4. Assign Motor IDs

        All motors ship with ID `1`. Assign unique IDs 1–10 one motor at a time:

        1. Plug in **one motor** to the U2D2 PHB.
        2. Open **Dynamixel Wizard 2.0** → Scan → change ID (1 through 10).
        3. Unplug; repeat for next motor.

        > Only after all 10 motors have unique IDs should you daisy-chain them together.

        ### 5. SSH to Raspberry Pi (if running untethered)

        ```powershell
        ssh smartsnake@snakerobo.local
        ```

        Full guide: Refer to [`Documentation/Progress_Report_25_Percent.pdf`](Documentation/Progress_Report_25_Percent.pdf)

        ---

        ## Running the Robot

        ### Verify All Motors

        ```bash
        python tests/test_dynamixel_ping.py
        ```

        Reports each motor ID found on the bus and explicitly lists any that are missing.

        ### Calibrate Obstacle Threshold

        ```bash
        python tests/test_motor_feedback.py
        ```

        Streams live Position / Velocity / Current (mA). Gently resist the horn to see the current spike that triggers obstacle detection.

        ### Start the Snake

        ```bash
        python main.py
        ```

        The snake initialises all motors, then begins the sinusoidal slither gait. Press **Ctrl + C** to halt — all motor torques are disabled cleanly in the `finally` block.

        ---

        ## Module Reference

        | Module | Class | Description |
        |---|---|---|
        | [`src/robot_config.py`](src/robot_config.py) | `Config`, `DynamixelAddr` | All hardware constants, tuning parameters, control table addresses |
        | [`src/utils.py`](src/utils.py) | — | `to_signed_current()` — XL330 two's complement current conversion |
        | [`src/snake_locomotion.py`](src/snake_locomotion.py) | `SnakeKinematics` | Sinusoidal gait: computes goal encoder positions for all joints |
        | [`src/obstacle_avoidance.py`](src/obstacle_avoidance.py) | `ObstacleAvoidance` | Current-based state machine; side-aware evasion turn direction |
        | [`src/kinematics.py`](src/kinematics.py) | `Kinematics` | Bellows-model curvature wave → joint angles (radians) |
        | [`src/servo_driver.py`](src/servo_driver.py) | `ServoDriver` | Hardware abstraction layer; mock simulation backend |
        | [`src/torque_controller.py`](src/torque_controller.py) | `TorqueController` | PD torque control with shape & radius modification modules |

        ### Gait Parameters (`src/robot_config.py`)

        | Parameter | Value | Description |
        |---|---|---|
        | `NUM_JOINTS` | 10 | Number of motors in daisy chain |
        | `ENCODER_CENTER` | 2048 | Neutral position (0° for XL330, range 0–4095) |
        | `OBSTACLE_CURRENT_THRESHOLD_MA` | 350 mA | Stall detection threshold |
        | `EVASION_REVERSE_DURATION_S` | 2.5 s | Time to reverse before turning |
        | `EVASION_TURN_DURATION_S` | 4.0 s | Time in turning gait before resuming |
        | `MAX_TORQUE_NM` | 0.52 Nm | XL330 stall torque (per ROBOTIS datasheet @ 5V) |

        ---

        ## CAD Files

        Designed in **SolidWorks**; exported to STEP and STL for cross-platform use.

        | File | Location | Description |
        |---|---|---|
        | [`Segment_v1.stl`](CAD/Segment_v1.stl) | `CAD/` | Primary body segment STL model |
        | [`Segment_v2.stl`](CAD/Segment_v2.stl) | `CAD/` | Secondary body segment STL model |
        | [`Assembly.step`](CAD/Assembly.step) | `CAD/` | Full 10-motor robot assembly STEP model |

        > Print settings: PLA or PETG recommended; 20% infill; 0.2 mm layer height.

        ---

        ## Documentation & Hardware Selection

        | Document | Path | Description |
        |---|---|---|
        | Interactive Hardware BOM | [`Hardware/BOM.xlsx`](Hardware/BOM.xlsx) | Full budget spreadsheet with formula totals |
        | Dynamixel Selection Guide | [`Hardware/Dynamixel_Selection.md`](Hardware/Dynamixel_Selection.md) | Technical comparison & actuator selection rationale |
        | Progress Report (25%) | [`Documentation/Progress_Report_25_Percent.pdf`](Documentation/Progress_Report_25_Percent.pdf) | Phase 1 milestone report |
        | Review Presentation | [`Documentation/Presentation.pptx`](Documentation/Presentation.pptx) | Review slides with system overview |
        | Sensor Node Simulation | [`Simulation/Wokwi/`](Simulation/Wokwi/) | ESP32 + HC-SR04 simulation in Wokwi |

        ---

        ## Team

        **SURGE-090 — Smart Snake Robot**
        Indian Institute of Technology Delhi — Summer 2026

        | Member | Role |
        |---|---|
        | Shashank Jangir | Project Lead / Software |
        | Bhavesh | Hardware & Mechanical |
        | Mahima | Electronics & Wiring |

        ---

        ## Acknowledgements

        This project was carried out under the **SURGE (Summer Undergraduate Research Grant for Excellence)** programme at **IIT Delhi**. We thank our project supervisor and the Department of Mechanical Engineering for their guidance and laboratory resources.

        ---

        ## License

        © 2026 SURGE-090 Team, IIT Delhi. All rights reserved.
        This repository is shared for academic and research purposes only.
