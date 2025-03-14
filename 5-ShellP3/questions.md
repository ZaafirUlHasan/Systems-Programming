1. Your shell forks multiple child processes when executing piped commands. How does your implementation ensure that all child processes complete before the shell continues accepting user input? What would happen if you forgot to call waitpid() on all child processes?

My implementation ensures this by calling waitpid() on each child process in both exec_cmd() and execute_pipeline(). If I forgot to call waitpid() on all child processes, zombie processes would accumulate because their exit statuses wouldn’t be collected by the parent process. This could eventually exhaust system resources, leading to unexpected behavior in the shell. Additionally, without waitpid(), the shell might accept new input before all commands in a pipeline finish executing, potentially leading to race conditions or unpredictable behavior.

2. The dup2() function is used to redirect input and output file descriptors. Explain why it is necessary to close unused pipe ends after calling dup2(). What could go wrong if you leave pipes open?

Pipes operate as file descriptors, and leaving them open in child processes can lead to issues such as unnecessary resource consumption and deadlocks. If a child process does not close unused pipe ends, the parent may wait indefinitely for EOF on a pipe that is still open elsewhere. For example, if the write end of a pipe remains open in a process that only needs to read from it, read() may block indefinitely, expecting more input. Similarly, keeping unnecessary read ends open in a process that only writes can cause write() operations to hang because the receiving process may not recognize when the data stream is complete. 

3. Your shell recognizes built-in commands (cd, exit, dragon). Unlike external commands, built-in commands do not require execvp(). Why is cd implemented as a built-in rather than an external command? What challenges would arise if cd were implemented as an external process?

I implemented cd as a built-in command because changing the working directory affects the shell process itself. If cd were an external command executed via execvp(), it would run in a separate child process, and any directory change would only apply to that child, not my shell. Once the child process exits, the shell would remain in the original directory, making cd useless. The main challenge of implementing cd as an external process is that the shell would need some way to communicate the directory change back to the parent process.


4. Currently, your shell supports a fixed number of piped commands (CMD_MAX). How would you modify your implementation to allow an arbitrary number of piped commands while still handling memory allocation efficiently? What trade-offs would you need to consider?

I would replace the fixed-size commandsCMD_MAX array in command_list_t with a dynamically allocated array using malloc(). Initially, I’d allocate a small number of slots (e.g., 4) and expand the array dynamically as more piped commands are parsed.  I’d also modify build_cmd_list() to resize this array as needed and adjust execute_pipeline() to dynamically allocate the pipes array instead of using a fixed-size stack allocation.

The main trade-offs involve memory management complexity and performance overhead. I’d need to free allocated memory after execution to prevent leaks carefully, and frequent realloc() calls may introduce some overhead. However, this approach offers greater flexibility, allowing users to run complex pipelines without hitting artificial limits. 
