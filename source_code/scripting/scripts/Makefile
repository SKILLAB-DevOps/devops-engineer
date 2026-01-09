# This is a comment
# The target is "hello" and the command to execute is below it

.PHONY: hello hello2 clean
# .PHONY is a special target that tells make that the target is not a file
# It is used to avoid conflicts with files of the same name

name=World

hello:
	@echo "Hello, World!"

hello2:
	@echo "Hello, $(name)!"

clean:
	@rm -f *.log

# Install the healthCheck script to /usr/local/bin
install:
	@echo "Installing healthCheck script to /usr/local/bin..."
	@sudo cp healthCheck /usr/local/bin
	@sudo chmod +x /usr/local/bin/healthCheck
	@echo "Installation complete."

# Remove the healthCheck script from /usr/local/bin
uninstall:
	@echo "Uninstalling healthCheck script from /usr/local/bin..."
	@sudo rm -f /usr/local/bin/healthCheck
	@echo "Uninstallation complete."

# Test the healthCheck script and save the output to healthCheck.log
test:
	@echo "Running healthCheck script..."
	@healthCheck > healthCheck.log
	@echo "Test complete. Output saved to healthCheck.log."