# SRS: Coffee Shop & Squash the Bug (feature_coffee_shop)

## 1. Introduction
### Purpose
Describe the functional and non-functional requirements for the project's monetization system and the interactive "Squash the Bug" feature.

### Scope
The feature is called **Coffee Shop**. It provides a way to support the project and rewards users with tiered features. It includes the **Squash the Bug** interactive game.

### Definitions & Abbreviations
- **Supporter Tier:** Categories of donation levels (1-3).
- **Squash the Bug:** An interactive mini-game for Tier 3 supporters.

### References
- [Core Architecture SRS](file:///e:/Github/sqa-tools/docs/srs/00_core.md)
- [Settings Dashboard SRS](file:///e:/Github/sqa-tools/docs/srs/plugin_settings.md)

## 2. Overall Description
### Product Perspective
This is a core component within SQA-Multitools, with its primary interface hosted in the Settings Dashboard.

### Product Functions
- **Donation Links:** Easy access to Ko-fi for project support.
- **Code Redemption:** Validating unique codes to unlock tiers.
- **Squash the Bug:** An interactive caterpillar asset for Tier 3 supporters.

### User Classes & Characteristics
- **Supporters (Admins/Donors):** Users who contribute financially.
- **Developers/QA:** Users looking for stress-relief or customization.

### Operating Environment
- **Platform:** Windows Desktop.

### Design & Implementation Constraints
- **State Management:** Riverpod (using `supporterTierProvider`).
- **Asset Integration:** Image assets for the bug game.

## 3. System Features (Functional Requirements)
### Redeem Receipt
- **Description:** Allow user to upgrade their tier by entering a code.
- **Inputs:** A 16-character receipt code.
- **Processing:** Validates the code's SHA-256 checksum locally.
- **Outputs:** Updated `supporterTier` value in preferences.

### Squash the Bug
- **Description:** Interactive bug-clicking game that traverses all four window borders.
- **Inputs:** Click on a Caterpillar image moving along any window edge.
- **Processing:** 
  - **Randomized Traversal:** Bug can appear on Top (Toolbar), Bottom, Left, or Right borders.
  - **Orientation Logic:** 8-way Matrix4 transformations ensure the bug always faces forward and stays "glued" to the border.
  - **Diagnostics:** Manual trigger buttons available in Settings for testing each border.
- **Outputs:** An animated "SQUASHED!" label and updated stats.

## 4. External Interface Requirements
### User Interfaces (UI)
- **Settings View:** Menu with coffee shop icons, description, and **Diagnostic Triggers** (Top, Bottom, Left, Right buttons) for the Bug Squasher.
- **Overlay:** The caterpillar overlay that traverses the main toolbar and window borders.

### Hardware Interfaces
- **Not implemented**.

### Software Interfaces
- **API:** Ko-fi (external link-only).

### Communication Interfaces
- **Protocol:** HTTPS via system browser for donations.

## 5. Non-Functional Requirements (Quality Attributes)
### Performance
- Animation efficiency: Low overhead on the main toolbar.

### Safety & Security
- **Asymmetric Encryption:** Uses Ed25519 digital signatures to prevent local code generation.
- **Cloudflare Worker:** Verification logic and master keys are stored server-side.
- **Binding Logic:** Prevents code sharing by binding one code to a specific email.

### Reliability
- Persistence: Supporter status 100% recovered on startup via local signature validation.
- Offline Mode: Once redeemed, no internet is required to maintain supporter status.

### Maintainability
- Maintained within `coffee_shop_service.dart`.
