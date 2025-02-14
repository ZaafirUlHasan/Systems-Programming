1. In this assignment I suggested you use `fgets()` to get user input in the main while loop. Why is `fgets()` a good choice for this application?

    > **Answer**:  fgets() is a good choice for this application because it safely reads an entire line of user input, including spaces, until a newline or the maximum buffer size is reached. It prevents buffer overflows by limiting input size based on the buffer provided, and it can handle empty input or EOF gracefully by returning NULL. This makes it ideal for a shell program where user commands may vary in length, and proper input handling is crucial to avoid crashes or unexpected behavior. Also, Since reading stops after an EOF or a newline, it makes it a suitable line-by-line processor.

2. You needed to use `malloc()` to allocte memory for `cmd_buff` in `dsh_cli.c`. Can you explain why you needed to do that, instead of allocating a fixed-size array?

    > **Answer**:  I used malloc() for cmd_buff to dynamically allocate memory on the heap instead of using a fixed-size stack array.  Heap allocation via malloc() is safer for larger or variable-sized data, ensures the buffer persists across loop iterations, and allows explicit memory management (e.g., free() on exit). While a fixed array could work here, dynamic allocation is a more flexible and defensive approach.




3. In `dshlib.c`, the function `build_cmd_list(`)` must trim leading and trailing spaces from each command before storing it. Why is this necessary? If we didn't trim spaces, what kind of issues might arise when executing commands in our shell?

    > **Answer**:  If spaces aren’t trimmed, strtok_r might treat them as part of the command or arguments, leading to incorrect parsing. For instance, an executable name with leading spaces could be misinterpreted as empty or invalid, and trailing spaces might cause unexpected blank arguments. Trimming ensures that strtok_r processes clean input, resulting in accurate command separation and proper execution in the shell.

4. For this question you need to do some research on STDIN, STDOUT, and STDERR in Linux. We've learned this week that shells are "robust brokers of input and output". Google _"linux shell stdin stdout stderr explained"_ to get started.

- One topic you should have found information on is "redirection". Please provide at least 3 redirection examples that we should implement in our custom shell, and explain what challenges we might have implementing them.

    > **Answer**:  Three common redirection examples to implement in our custom shell are output redirection, input redirection, pipe redirection. Output redirection redirects STDOUT to a file, e.g., ls > output.txt. 
Input redirection redirects STDIN from a file, e.g., sort < input.txt. And, pipe redirection (|) sends STDOUT of one command as STDIN to another, e.g., ls | grep .c.

The challenge with these is handling file I/O operations, ensuring the file is created/written correctly, and modifying the shell to replace the correct file descriptor.
    

- You should have also learned about "pipes". Redirection and piping both involve controlling input and output in the shell, but they serve different purposes. Explain the key differences between redirection and piping.

    > **Answer**:  Redirection is used to change the source of input or destination of output for a single command, such as sending output to a file (>), or reading input from a file (<). Piping (|), on the other hand, connects the output of one command directly as the input to another, allowing multiple commands to work together in a chain. While redirection works with files, pipes work between processes, making them more dynamic for passing data in real-time without creating intermediate files.

- STDERR is often used for error messages, while STDOUT is for regular output. Why is it important to keep these separate in a shell?

    > **Answer**:  Keeping STDERR and STDOUT separate is important because it allows error messages to be displayed independently of regular command output. This helps users distinguish between successful results and errors, making debugging easier. For example, if a command generates both output and an error, mixing them could cause confusion, especially when output is redirected to a file. By keeping them separate, you can redirect the output to a file while still seeing error messages on the terminal.

- How should our custom shell handle errors from commands that fail? Consider cases where a command outputs both STDOUT and STDERR. Should we provide a way to merge them, and if so, how?

    > **Answer**:  If a command generates both STDOUT and STDERR, the shell should ideally keep them separate by default, allowing the user to distinguish regular output from errors. However, it might be useful to provide an option to merge them, especially in cases where all output (including errors) needs to be logged or processed together.


To merge STDOUT and STDERR, we could implement a feature where users can specify redirection of both streams to the same file, e.g., command > output.txt 2>&1. The 2>&1 syntax combines both the output and error streams. Internally, the shell would redirect STDERR (file descriptor 2) to STDOUT (file descriptor 1) so that both streams are captured into the same destination.
