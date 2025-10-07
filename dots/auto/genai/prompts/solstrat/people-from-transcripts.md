
# Task

Your goal is to maintain a comprehensive 00_PEOPLE.md file that serves as a people directory for stakeholders involved in the project.

## Key Exclusions
- Ignore any people from vendor/partner organizations (these should be tracked separately)
- Only track client organization employees and contractors

## Document Structure

### 1. Header
```
# People Directory - [Client Organization Name]
```

### 2. Organizational Units Overview
Create an ASCII tree showing the organizational hierarchy discovered from transcripts:
```
# Units

[Organization Name]
├── [Division/Unit 1]
│   ├── [Sub-unit]
│   └── [Sub-unit]
│
├── [Division/Unit 2]
│   └── [Sub-unit]
│
└── [Division/Unit 3]
    └── [Sub-unit]
```

### 3. Unit Descriptions
For each major unit mentioned, provide a brief overview based on context from transcripts:
```
## [Unit Name]

[Brief description of the unit's purpose and responsibilities based on meeting context]

This includes:
- [Key responsibility 1]
- [Key responsibility 2]
- [Key responsibility 3]

[Additional context about how this unit relates to the project]
```

### 4. People Section
Organize people by their business unit with the following format:

```
# People

## [Business Unit Name]

### Name: [Person Name]
- **Engagement**: [0-10 score based on frequency of mentions/participation]
- **Email**: [email@domain.com]
- **Role**: [Title/Position]
- **Unit**: [Business Unit/Division]
- **Manager**: [Manager Name or blank if unknown]
- **Reports**: [List of direct reports or blank if none/unknown]

#### Remit
[~100 word summary of this person's responsibilities within their org. Write in business language that explains their role to someone unfamiliar with the organization.]

#### Focus
[~100 word summary of the subjects/key areas this person often focuses on based on meeting participation and discussions.]

---
```

### 5. Footer
```
# Source Information

This document was compiled from transcript files dated between [start date] and [end date]. 
Information accuracy is based on explicit mentions in meeting transcripts. Where information was unclear or conflicting, this has been noted. Email addresses marked with contractor status indicators should be noted appropriately.

Last updated: [current date]
```

# Process Requirements

## Information Gathering
- Read each transcript file systematically
- Extract all person mentions with their context
- Note the date and meeting context for each piece of information

## Data Quality Rules
1. **Engagement Scoring**:
   - 10: Primary POC, speaks in most meetings
   - 8-9: Regular active participant
   - 5-7: Occasional participant
   - 2-4: Mentioned but rarely present
   - 0-1: Named but minimal involvement

2. **Email Handling**:
   - Use exact email addresses when mentioned
   - Mark contractor emails appropriately
   - Leave blank if not mentioned

3. **Name Resolution**:
   - Combine variations (e.g., "Bala" and "Balachandar")
   - Use most formal/complete version as primary
   - Note aliases in remit if relevant

4. **Unknown Information**:
   - Leave fields blank rather than guessing
   - Add "[Information not available in transcripts]" for remit/focus if person is barely mentioned

## Writing Style
- Use clear business language
- Avoid technical jargon where possible
- Focus on role and impact rather than just titles
- Make connections between people and projects clear

## Quality Checks
- Ensure manager/report relationships are bidirectional
- Verify unit assignments make organizational sense
- Flag any conflicting information with dates
- NO HALLUCINATIONS - only include verifiable information from transcripts

# Key Success Criteria
1. Complete coverage of all target company stakeholders mentioned (ignore known pricefx staff or partner staff)
2. Clear organizational structure visualization
3. Practical descriptions that help readers understand each person's role
4. Accurate representation of involvement levels
5. Professional document suitable for project reference
