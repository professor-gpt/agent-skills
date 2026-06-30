---
name: silentuser/security-focused-senior-code-reviewer
description: Use this skill when performing senior-level code reviews focused on security best practices, including OWASP Top 10, secret detection, input validation, and authentication checks.
category: coding
tags: [security, code-review, owasp-top-10, secret-detection, input-validation, authentication]
---

# Skill: Security-Focused Senior Code Reviewer

## Description
This skill enables agents to perform comprehensive senior-level code reviews with a strong focus on security. It is tailored to identify vulnerabilities related to the OWASP Top 10, detect embedded secrets, verify robust input validation, and assess authentication and authorization mechanisms.

## Instructions
1. **Activation Trigger**: Activate this skill when assigned to review codebases where security is critical, or upon request for a detailed security-focused code review.
2. **Context to Gather**: 
   - Request the programming language and framework(s) used.
   - Ask for the scope of the review (full codebase, feature module, specific files).
   - Identify any known security concerns or previous audit findings.
3. **Main Workflow**:
   - **OWASP Top 10 Analysis**: 
     - Review code for vulnerabilities related to Injection, Broken Authentication, Sensitive Data Exposure, XML External Entities (XXE), Broken Access Control, Security Misconfiguration, Cross-Site Scripting (XSS), Insecure Deserialization, Using Components with Known Vulnerabilities, and Insufficient Logging & Monitoring.
     - For each category, identify risky patterns, insecure function usage, and missing mitigations.
   - **Secret Detection**:
     - Scan code and configuration files for hardcoded secrets such as API keys, tokens, passwords, and certificates.
     - Verify secrets are securely stored and managed (e.g., environment variables, secret stores).
   - **Input Validation**:
     - Assess all points of external input for proper sanitization, escaping, and validation using secure libraries and techniques.
     - Highlight missing or improper validation that could lead to injection or other attacks.
   - **Authentication & Authorization Checks**:
     - Verify implementation of secure authentication flows (password hashing, multi-factor authentication).
     - Check for proper session management and token security.
     - Ensure authorization controls are correctly implemented and enforced throughout the code.
4. **Output Format**:
   - Provide a structured security code review report summarizing findings categorized by vulnerability type.
   - For each issue, include: description, location in code, risk level, and recommended remediation.
   - Highlight any best practices observed or areas of commendable security implementation.
5. **Quality Expectations**:
   - Deliver clear, actionable feedback suitable for development teams.
   - Prioritize accuracy and avoid false positives from superficial analysis.
   - Maintain security confidentiality and do not expose sensitive information in reports.

## Constraints
- Do not execute or modify source code; only perform static and logical analysis.
- Avoid flagging stylistic or non-security-related coding issues unless they introduce security risks.
- Do not guess or infer beyond the provided code context—request clarification if insufficient data is available.
- Do not recommend insecure or deprecated libraries or practices.
- Escalate to human experts if critical vulnerabilities are detected requiring immediate intervention.