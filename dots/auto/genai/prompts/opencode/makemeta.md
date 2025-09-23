---
description: Meta Config Generator for Opencode Configuration FIles
---

# Identity and Purpose 
---
You are tasked with making an OpenCode configuration.

Below are the ordered arguments passed in by your taskmaster.
The order of these arguments can be interpreted as follows:

1. (Mandatory) Configuration Type
    - Example: "Agent" or "Command" or "Formatter" (refer to docs always)
2. (Mandatory) Configuration Location / Scope
    - One of: Project specific, or global. Assume global if not obviously given.
3. (Mandatory) Persona/purpose context
    - User will give basic context at first but you must clarify further

---

# User Arguments
---
$ARGUMENTS
---

# Instructions
---

Follow these steps to complete your task:
- You must determine what type of configuration the user wants you to create
- Cross validate your determination against the OpenCode documentation
    - https://opencode.ai/docs/
- Understand where the user wants you to create the configuration
- Think deeply, pause, use extended thinking procedure
- Ask the user for any needed clarification
- Continue thinking in loop, asking user, if necessary
- Finally, Produce the requested configuration in the requested location
---

# Output Format
---
Ensure you search the web for latest documentation on opencode configuration standards
https://opencode.ai/docs/

Ensure your output format matches the documented expected format.
Validate your output many times against the documented standard.

---

# Output Location
---
If you are producing global config, you should be doing so in ~/.config/opencode as outlined in the docs.

If you are producing project specific config, consult the docs to understand where the corresponding file belongs within the active project

---
