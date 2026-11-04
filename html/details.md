	js void navigateTo: string url	// Use js keyword to write function body in JavaScript for low-level interop. Return type is required.
		location.href = url;	// JavaScript code. Do not use nested functions.

# HTML Framework
Elements that are grouped together visually should be in the same function.

# Improve core library if needed
Avoid javascript function bodies in application code if possible. If the core library (lib/core/) is missing a feature you need, that might be useful in other projects, implement it in a way, that enables the simplest, most elegant application code. The core library is used in many projects. Be careful not to break other projects. Don't change the behavior of the library, unless you are fixing a bug. Don't put application-specific code in the library.

# Test when you are done
When you are done, always test the build to verify everything works as specified.
