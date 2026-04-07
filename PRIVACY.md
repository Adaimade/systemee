# System Eagle Eye — Privacy Notice

**Last updated: April 2026**

This document describes how **System Eagle Eye** (the “Software”) handles user-related settings and system information. The Software is open source under the **MIT License**; by using it you acknowledge that you have read and understand this notice.

---

## 1. Academic research and educational use

The Software is provided **only for academic research, teaching demonstrations, and personal learning**, as a sample of macOS system APIs and local monitoring UI.

- The Software **does not constitute** professional system administration, security auditing, performance tuning, or medical or legal advice.
- The author **does not** offer the Software as a commercial service or guarantee any particular outcome; you are responsible for suitability in your environment and compliance obligations.
- If you use the Software in courses, papers, or experiments, **cite the project** (name and license) where appropriate and follow your institution’s research ethics and information-security policies.

---

## 2. What we do not do (no outbound transmission)

Based on the published source and standard build, the Software **does not**:

- **Upload, sync, or transmit** personal data, usage logs, or metric values to the author or third-party servers over the internet;
- Include ads, analytics, tracking, or third-party SDKs;
- Read or upload file contents, communications, passwords, or the clipboard;
- Record screen or audio, or remotely control other applications.

The Software is **not designed as a networked service**. If you obtain a binary modified by a third party, verify its behavior and provenance yourself.

---

## 3. Data processed on device

### 3.1 Preferences

- **Storage:** standard macOS **UserDefaults** (suite: `com.systemee.SystemEagleEye`), typically under your user’s preferences on disk.
- **Content:** toggles for menu bar / info card sections, polling interval, and similar **settings**—**not** names, accounts, contact details, or identifiers.

### 3.2 System statistics (computed and displayed in memory only)

To show metrics, the Software reads **aggregated** information **locally** through Apple’s public system interfaces, for example:

- CPU utilization–related statistics;
- Memory and virtual-memory counters;
- Boot volume capacity and free space;
- **Totals** for process and thread counts (the code does not transmit process name lists externally).

This information is used **only** to refresh the menu bar and info card on your machine and is **not** actively sent off the device by the Software.

### 3.3 Physical visibility

Numbers in the menu bar and info card may be **seen by others** near your screen, like any on-screen content. That is not a network-privacy issue; exercise judgment in public settings.

---

## 4. Children and regulated environments

The Software is not an online service aimed at children and is not designed to collect children’s personal data. If you use it in a regulated research setting, follow that environment’s IRB, privacy, and security policies.

---

## 5. Changes and contact

- This notice may be updated as the project evolves; the **latest version in this repository** governs.
- There is no dedicated support line for the open-source project; use repository **Issues** or your platform’s channels to reach maintainers for technical or licensing topics.

---

## 6. Summary

| Topic | Summary |
|--------|---------|
| Intended use | **Academic research, teaching, and personal learning only**—not a commercial warranty or professional advisory tool. |
| Networking / uploads | **No** designed data uploads or third-party tracking. |
| Local storage | Preferences plus on-device reads for live display only. |
| License | See **LICENSE** (MIT) in the repository root. |
