1. Can you think of why we use `fork/execvp` instead of just calling `execvp` directly? What value do you think the `fork` provides?

    > **Answer**:  Using fork() before execvp() allows the parent process to create a child process, ensuring that the parent process continues running independently while the child executes the new program. If execvp() were called directly, it would replace the current process, terminating the shell. fork() provides concurrency, allowing the shell to handle multiple commands and maintain its state.



2. What happens if the fork() system call fails? How does your implementation handle this scenario?

    > **Answer**:  If fork() fails, it returns -1, and the child process is not created. In the implementation, this is handled by printing an error message using perror("Fork failed"), allowing the parent process to continue running and prompting the user for the next command.

3. How does execvp() find the command to execute? What system environment variable plays a role in this process?

    > **Answer**:  execvp() uses the PATH environment variable to locate the executable file for the command. It searches through the directories listed in PATH in order, executing the first matching executable it finds.

4. What is the purpose of calling wait() in the parent process after forking? What would happen if we didn’t call it?

    > **Answer**: wait() ensures the parent process pauses until the child process completes. Without it, the parent might continue executing, potentially leading to zombie processes (defunct processes that have completed but remain in the process table).

5. In the referenced demo code we used WEXITSTATUS(). What information does this provide, and why is it important?

    > **Answer**:  WEXITSTATUS() extracts the exit status of a child process, which is important for determining whether the command executed successfully or encountered an error. This helps the shell handle errors or provide feedback to the user.

6. Describe how your implementation of build_cmd_buff() handles quoted arguments. Why is this necessary?

    > **Answer**:  build_cmd_buff() handles quoted arguments by toggling a flag (in_quotes) when encountering double quotes ("). This ensures that spaces within quotes are treated as part of the argument rather than separators. This is necessary to support commands with arguments containing spaces, such as filenames or strings.

7. What changes did you make to your parsing logic compared to the previous assignment? Were there any unexpected challenges in refactoring your old code?

    > **Answer**:  _start here_

8. For this quesiton, you need to do some research on Linux signals. You can use [this google search](https://www.google.com/search?q=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&oq=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBBzc2MGowajeoAgCwAgA&sourceid=chrome&ie=UTF-8) to get started.

- What is the purpose of signals in a Linux system, and how do they differ from other forms of interprocess communication (IPC)?

    > **Answer**:  Signals are used to notify processes of events, such as interrupts or termination requests. Unlike IPC mechanisms (e.g., pipes or shared memory), signals are asynchronous and typically used for simple notifications or process control rather than data exchange.

- Find and describe three commonly used signals (e.g., SIGKILL, SIGTERM, SIGINT). What are their typical use cases?

    > **Answer**:  SIGKILL forces a process to terminate immediately. It cannot be caught or ignored, making it useful for stopping unresponsive processes. SIGTERM requests a process to terminate gracefully. It can be caught or ignored, allowing the process to clean up resources before exiting. SIGINT is sent when the user presses Ctrl+C. It interrupts the process, typically used to stop running commands in a terminal.

- What happens when a process receives SIGSTOP? Can it be caught or ignored like SIGINT? Why or why not?

    > **Answer**: SIGSTOP pauses the process, placing it in a stopped state. Unlike SIGINT, it cannot be caught or ignored, as it is designed to unconditionally suspend the process until it receives SIGCONT to resume execution.
