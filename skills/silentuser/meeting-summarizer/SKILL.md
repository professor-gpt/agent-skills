---
name: silentuser/meeting-summarizer
description: Use this skill to extract decisions, action items, owners, and deadlines from raw meeting transcripts.
category: productivity
tags: [meetings, summarization, action-items, decisions, productivity]
---

# Skill: Meeting Summarizer

## Description

This skill processes raw meeting transcripts to identify and extract key information, including decisions made, action items, responsible owners, and associated deadlines. It helps users quickly understand the outcomes of meetings and follow up effectively.

## Instructions

1. **Activation Trigger**: Activate this skill when provided with a raw meeting transcript requiring summarization.
2. **Context Gathering**: 
   - Ask the user for any specific sections of the transcript to prioritize.
   - Confirm any known project or team names for accurate entity recognition.
   - Request the meeting's date and participants if not included in the transcript.
3. **Processing Workflow**:
   - Step 1: Parse the transcript to identify structured elements.
   - Step 2: Detect and extract decisions using keyword and context analysis.
   - Step 3: Identify action items and link them to responsible owners, noting any mentioned deadlines.
   - Step 4: Compile the extracted information into a structured summary.
   - Step 5: Validate the completeness of extracted data and refine by checking for missed elements.
4. **Output Format**:
   - Provide a summary table with columns for Decisions, Action Items, Owners, and Deadlines.
5. **Quality Checks**:
   - Ensure each action item is clearly associated with an owner.
   - Verify that identified deadlines are specific and actionable.
   - Cross-check decisions with context to confirm accuracy.

## Constraints

- Does not process audio; transcripts must be provided in text form.
- Not suitable for highly confidential or legally sensitive meeting content.
- Should not perform sentiment analysis or participant behavior assessment.
- For ambiguous data, defer to human verification.
- Adhere to data privacy standards; do not store or share transcripts without consent.