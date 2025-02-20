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
// int exec_local_cmd_loop()
// {
//     char *cmd_buff;
//     int rc = 0;
//     cmd_buff_t cmd;

//     // TODO IMPLEMENT MAIN LOOP

//     // TODO IMPLEMENT parsing input to cmd_buff_t *cmd_buff

//     // TODO IMPLEMENT if built-in command, execute builtin logic for exit, cd (extra credit: dragon)
//     // the cd command should chdir to the provided directory; if no directory is provided, do nothing

//     // TODO IMPLEMENT if not built-in command, fork/exec as an external command
//     // for example, if the user input is "ls -l", you would fork/exec the command "ls" with the arg "-l"

//     return OK;
// }

int exec_local_cmd_loop()
{
    char cmd_buff[SH_CMD_MAX];
    cmd_buff_t cmd;

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
            printf("%s", CMD_WARN_NO_CMD);
            continue;
        }

        if (alloc_cmd_buff(&cmd) != OK)
        {
            printf("Memory allocation error\n");
            continue;
        }

        if (build_cmd_buff(cmd_buff, &cmd) != OK)
        {
            printf("Error parsing command\n");
            free_cmd_buff(&cmd);
            continue;
        }

        Built_In_Cmds cmd_type = exec_built_in_cmd(&cmd);
        if (cmd_type == BI_CMD_EXIT)
        {
            free_cmd_buff(&cmd);
            break;
        }
        else if (cmd_type == BI_NOT_BI)
        {
            pid_t pid = fork();
            if (pid == 0)
            {
                execvp(cmd.argv[0], cmd.argv);
                perror("Execution failed");
                exit(ERR_EXEC_CMD);
            }
            else if (pid > 0)
            {
                wait(NULL);
            }
            else
            {
                perror("Fork failed");
            }
        }

        free_cmd_buff(&cmd);
    }

    return OK;
}

Built_In_Cmds match_command(const char *input) {
    if (input == NULL || strlen(input) == 0) {
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

int alloc_cmd_buff(cmd_buff_t *cmd_buff)
{
    cmd_buff->_cmd_buffer = malloc(SH_CMD_MAX);
    if (!cmd_buff->_cmd_buffer)
    {
        return ERR_MEMORY;
    }
    cmd_buff->argc = 0;
    return OK;
}

int free_cmd_buff(cmd_buff_t *cmd_buff)
{
    if (cmd_buff->_cmd_buffer)
    {
        free(cmd_buff->_cmd_buffer);
        cmd_buff->_cmd_buffer = NULL;
    }
    return OK;
}

int clear_cmd_buff(cmd_buff_t *cmd_buff)
{
    memset(cmd_buff->_cmd_buffer, 0, SH_CMD_MAX);
    cmd_buff->argc = 0;
    return OK;
}


int build_cmd_buff(char *cmd_line, cmd_buff_t *cmd_buff) {
    if (!cmd_line || !cmd_buff) {
        return ERR_CMD_ARGS_BAD;
    }

    cmd_buff->argc = 0;
    cmd_buff->_cmd_buffer = strdup(cmd_line);
    if (!cmd_buff->_cmd_buffer) {
        return ERR_MEMORY;
    }

    char *trimmed_cmd = cmd_buff->_cmd_buffer;
    char *end = trimmed_cmd + strlen(trimmed_cmd);

    // Trim leading spaces
    while (*trimmed_cmd && (*trimmed_cmd == SPACE_CHAR)) {
        trimmed_cmd++;
    }

    // Trim trailing spaces
    while (end > trimmed_cmd && (*(end - 1) == SPACE_CHAR)) {
        *(--end) = '\0';
    }

    bool in_quotes = false;
    char *token_start = NULL;

    for (char *current_char = trimmed_cmd; *current_char; current_char++) {
        if (*current_char == '"') {
            in_quotes = !in_quotes;
            // Skip storing the quote character
            continue;
        }

        if ((*current_char == SPACE_CHAR) && !in_quotes) {
            *current_char = '\0';
            if (token_start) {
                cmd_buff->argv[cmd_buff->argc++] = token_start;
                token_start = NULL;
            }
        } else if (!token_start) {
            token_start = current_char;
        }
    }

    // Handle the last token if it exists
    if (token_start) {
        // If the last token ends with a quote, remove it
        char *last_char = token_start + strlen(token_start) - 1;
        if (*last_char == '"') {
            *last_char = '\0';  // Remove the trailing quote
        }
        cmd_buff->argv[cmd_buff->argc++] = token_start;
    }

    cmd_buff->argv[cmd_buff->argc] = NULL;

    return OK;
}