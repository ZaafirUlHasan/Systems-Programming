#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>

#include "dshlib.h"

/*
 * Implement your exec_local_cmd_loop function by building a loop that prompts the 
 * user for input.  Use the SH_PROMPT constant from dshlib.h and then
 * use fgets to accept user input.
 * 
 *      while(1){
 *        printf("%s", SH_PROMPT);
 *        if (fgets(cmd_buff, ARG_MAX, stdin) == NULL){
 *           printf("\n");
 *           break;
 *        }
 *        //remove the trailing \n from cmd_buff
 *        cmd_buff[strcspn(cmd_buff,"\n")] = '\0';
 * 
 *        //IMPLEMENT THE REST OF THE REQUIREMENTS
 *      }
 * 
 *   Also, use the constants in the dshlib.h in this code.  
 *      SH_CMD_MAX              maximum buffer size for user input
 *      EXIT_CMD                constant that terminates the dsh program
 *      SH_PROMPT               the shell prompt
 *      OK                      the command was parsed properly
 *      WARN_NO_CMDS            the user command was empty
 *      ERR_TOO_MANY_COMMANDS   too many pipes used
 *      ERR_MEMORY              dynamic memory management failure
 * 
 *   errors returned
 *      OK                     No error
 *      ERR_MEMORY             Dynamic memory management failure
 *      WARN_NO_CMDS           No commands parsed
 *      ERR_TOO_MANY_COMMANDS  too many pipes used
 *   
 *   console messages
 *      CMD_WARN_NO_CMD        print on WARN_NO_CMDS
 *      CMD_ERR_PIPE_LIMIT     print on ERR_TOO_MANY_COMMANDS
 *      CMD_ERR_EXECUTE        print on execution failure of external command
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 1+)
 *      malloc(), free(), strlen(), fgets(), strcspn(), printf()
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 2+)
 *      fork(), execvp(), exit(), chdir()
 */

 int exec_local_cmd_loop()
 {
     char cmd_buff[SH_CMD_MAX];
     command_list_t clist;
 
     while (1)
     {
         printf("%s", SH_PROMPT);
         if (fgets(cmd_buff, SH_CMD_MAX, stdin) == NULL)
         {
             printf("\n");
             break;
         }
 
         cmd_buff[strcspn(cmd_buff, "\n")] = '\0'; 
 
         if (strlen(cmd_buff) == 0)
         {
             printf(CMD_WARN_NO_CMD);
             continue;
         }
 
         memset(&clist, 0, sizeof(command_list_t));
         if (build_cmd_list(cmd_buff, &clist) != OK)
         {
             printf("Error parsing command line\n");
             continue;
         }
 
         if (clist.num == 0)
         {
             printf(CMD_WARN_NO_CMD);
             continue;
         }
 
         // Handle built-in commands for single command execution
         if (clist.num == 1)
         {
             Built_In_Cmds cmd_type = exec_built_in_cmd(&clist.commands[0]);
             if (cmd_type == BI_CMD_EXIT)
             {
                 break;
             }
             else if (cmd_type == BI_NOT_BI)
             {
                 exec_cmd(&clist.commands[0]);
             }
         }
         else
         {
             execute_pipeline(&clist);
         }
     }
 
     return OK;
 }
 

 Built_In_Cmds exec_built_in_cmd(cmd_buff_t *cmd)
 {
     Built_In_Cmds cmd_type = match_command(cmd->argv[0]);
     if (cmd_type == BI_CMD_CD)
     {
         if ((cmd->argc > 1) && (chdir(cmd->argv[1]) != 0))
         {
             perror("cd failed");
         }
     }
     return cmd_type;
 }

 Built_In_Cmds match_command(const char *input) {
    if ((input == NULL) || (strlen(input) == 0)) {
        return BI_NOT_BI;
    }
    
    if (strcmp(input, "exit") == 0) {
        return BI_CMD_EXIT;
    } else if (strcmp(input, "cd") == 0) {
        return BI_CMD_CD;
    } else if (strcmp(input, "dragon") == 0) {  // Extra credit command
        return BI_CMD_DRAGON;
    }
    
    return BI_NOT_BI;
}

int build_cmd_list(char *cmd_line, command_list_t *clist) {
    if ((cmd_line == NULL) || (strlen(cmd_line) == 0)) {
        return WARN_NO_CMDS;
    }

    memset(clist, 0, sizeof(command_list_t));
    
    char *saveptr_pipe;
    char *token = strtok_r(cmd_line, PIPE_STRING, &saveptr_pipe);
    int cmd_count = 0;

    while (token != NULL) {
        while (*token == SPACE_CHAR) // Remove leading spaces
            token++;

        char *end = token + strlen(token) - 1;
        while ((end > token) && (*end == SPACE_CHAR)) // Remove trailing spaces
            *end-- = '\0';

        if (cmd_count >= CMD_MAX) {
            return ERR_TOO_MANY_COMMANDS;
        }

        clist->commands[cmd_count]._cmd_buffer = strdup(token);
        if (clist->commands[cmd_count]._cmd_buffer == NULL) {
            return ERR_CMD_OR_ARGS_TOO_BIG;
        }

        char *cmd_str = clist->commands[cmd_count]._cmd_buffer;
        bool in_quotes = false;
        char *arg_start = NULL;
        int arg_count = 0;

        for (char *ptr = cmd_str; *ptr; ptr++) {
            if (*ptr == '"') {
                in_quotes = !in_quotes;
                memmove(ptr, ptr + 1, strlen(ptr)); // Shift the rest left, removing the quote
                ptr--; // Adjust pointer back
                continue;
            }

            if ((*ptr == SPACE_CHAR) && !in_quotes) {
                *ptr = '\0'; // Null-terminate argument
                if (arg_start) {
                    clist->commands[cmd_count].argv[arg_count++] = arg_start;
                    arg_start = NULL;
                }
            } else if (!arg_start) {
                arg_start = ptr;
            }
        }

        // add the last argument
        if (arg_start) {
            clist->commands[cmd_count].argv[arg_count++] = arg_start;
        }

        clist->commands[cmd_count].argv[arg_count] = NULL; // Null-terminate argv
        clist->commands[cmd_count].argc = arg_count;
        
        cmd_count++;
        token = strtok_r(NULL, PIPE_STRING, &saveptr_pipe);
    }

    clist->num = cmd_count;
    return OK;
}



int exec_cmd(cmd_buff_t *cmd) {
    if (cmd == NULL || cmd->argc == 0 || cmd->argv[0] == NULL) {
        return -1; // Invalid command
    }

    pid_t pid = fork();
    if (pid < 0) {
        perror("fork failed");
        return -1;
    }

    if (pid == 0) { // Child process
        execvp(cmd->argv[0], cmd->argv);
        perror("execvp failed"); 
        exit(EXIT_FAILURE);
    } 

    // Parent process
    int status;
    waitpid(pid, &status, 0);

    if (WIFEXITED(status)) {
        return WEXITSTATUS(status); // Return child's exit status
    } else {
        return -1; // Abnormal termination
    }
}



int execute_pipeline(command_list_t *clist) {
    if (clist == NULL || clist->num == 0) {
        return -1; 
    }

    int num_cmds = clist->num;
    int pipes[num_cmds - 1][2];
    pid_t pids[num_cmds];

    // Create pipes
    for (int i = 0; i < num_cmds - 1; i++) {
        if (pipe(pipes[i]) < 0) {
            perror("pipe failed");
            return -1;
        }
    }

    for (int i = 0; i < num_cmds; i++) {
        pids[i] = fork();
        if (pids[i] < 0) {
            perror("fork failed");
            return -1;
        }

        if (pids[i] == 0) { // Child process
            // Input redirection (not first command)
            if (i > 0) {
                dup2(pipes[i - 1][0], STDIN_FILENO);
            }
            // Output redirection (not last command)
            if (i < num_cmds - 1) {
                dup2(pipes[i][1], STDOUT_FILENO);
            }

            // Close unused pipes in child
            for (int j = 0; j < num_cmds - 1; j++) {
                if (j != i - 1) close(pipes[j][0]); 
                if (j != i) close(pipes[j][1]);   
            }

            execvp(clist->commands[i].argv[0], clist->commands[i].argv);
            perror("execvp failed");
            exit(EXIT_FAILURE);
        }
    }

    // Close only write ends in parent
    for (int i = 0; i < num_cmds - 1; i++) {
        close(pipes[i][1]);
    }

    // Wait for all children
    int status;
    for (int i = 0; i < num_cmds; i++) {
        waitpid(pids[i], &status, 0);
    }

    return OK_EXIT;
}