#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

RDSH_DEF_PORT=3769
RDSH_DEF_SVR_INTFACE="0.0.0.0"
RDSH_DEF_CLI_CONNECT="127.0.0.1"

setup() {
    ./dsh -s ${RDSH_DEF_SVR_INTFACE}:${RDSH_DEF_PORT} &
    SERVER_PID=$!
    sleep 1
}

teardown() {
    if ps -p $SERVER_PID > /dev/null; then
        kill $SERVER_PID
    fi
    sleep 1
}








@test "Local: Example: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

# Test basic LOCAL command execution
@test "Local: Basic Command Execution" {
    run "./dsh" <<EOF                
echo Hello, World!
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="Hello,World!localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test pipes
@test "Local: Pipes" {
    run "./dsh" <<EOF                
ls | grep dshlib.c
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="dshlib.clocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test multiple pipes
@test "Local: Local: Multiple Pipes" {
    run "./dsh" <<EOF                
echo "Hello World" | tr " " "\n" | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="2localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test built-in cd command
@test "Local: Built-in cd" {
    run "./dsh" <<EOF                
cd /
pwd
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="/localmodedsh4>dsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test exit command
@test "Local: Exit Command" {
    run "./dsh" <<EOF                
exit
EOF
    [ "$status" -eq 0 ]
}

# Test quoting
@test "Local: Quoting" {
    run "./dsh" <<EOF                
echo "Hello World"
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="HelloWorldlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test leading and trailing spaces
@test "Local: Whitespace Handling" {
    run "./dsh" <<EOF                
    echo Test    
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="Testlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test empty input
@test "Local: Empty Input" {
    run "./dsh" <<EOF                

EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="localmodedsh4>warning:nocommandsprovideddsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test invalid command
@test "Local: Invalid Command" {
    run "./dsh" <<EOF                
asdfghjkl
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="execvpfailed:Nosuchfileordirectorylocalmodedsh4>localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}



















# Basic single pipe test
@test "Local: Simple Pipe ls | grep dshlib.c" {
    run "./dsh" <<EOF
ls | grep dshlib.c
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="dshlib.clocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe with three commands
@test "Local: Triple Pipe: ls | grep dsh | wc -l" {
    run "./dsh" <<EOF
ls | grep -w dsh | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="1localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe where first command has no output
@test "Local: Pipe from empty command: echo '' | grep test" {
    run "./dsh" <<EOF
echo '' | grep test
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="localmodedsh4>dsh4>cmdloopreturned0"  # No output from grep

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe with cat and grep
@test "Local: Pipe with cat and grep: cat dshlib.h | grep '#define'" {
    run "./dsh" <<EOF
cat dshlib.h | grep "exec_local_cmd_loop"
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    
    expected_output="intexec_local_cmd_loop();localmodedsh4>dsh4>cmdloopreturned0" 

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe to sort, uniq, and wc
@test "Local: Sort and Count Unique Lines: cat dshlib.h | sort | uniq | wc -l" {
    run "./dsh" <<EOF
cat dshlib.h | sort | uniq | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    
    expected_output="75localmodedsh4>dsh4>cmdloopreturned0"  

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe with invalid command in middle
@test "Local: Invalid Command in Pipe: ls | nonexistentcommand | wc -l" {
    run "./dsh" <<EOF
ls | nonexistentcommand | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    
    expected_output="execvpfailed:Nosuchfileordirectory1localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}



# Pipe with trailing spaces
@test "Local: Pipe with Trailing Spaces: ls | grep dsh " {
    run "./dsh" <<EOF
ls | grep -w dsh      
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="dshlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}


# Pipe using echo as input
@test "Local: Echo Pipe: echo 'hello world' | grep hello" {
    run "./dsh" <<EOF
echo "hello world" | grep hello
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="helloworldlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}




@test "Remote: Client can connect to server" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
exit
EOF

    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}


@test "Remote: Check ls runs without errors" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
ls
EOF
    # Assertions
    [ "$status" -eq 0 ]
}

# Test basic REMOTE command execution
@test "Remote: Basic Command Execution" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
echo Hello, World!
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>Hello,World!dsh4>clientexited:gettingnextconnection...cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test pipes
@test "Remote: Pipes" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF               
exit
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>clientexited:gettingnextconnection...cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}








# Test multiple pipes
@test "Remote: Multiple Pipes" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF           
echo "Hello World" | tr " " "\n" | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>2dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}


# Test under limit pipes
@test "Remote: 6(under limit) pipes" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF           
echo "Hello World" | cat  | cat  | cat  | cat  | cat  | cat
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>HelloWorlddsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}


# Test limit pipes
@test "Remote: 7(limit) pipes" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF           
echo "Hello World" | cat  | cat  | cat  | cat  | cat  | cat  | cat  
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>HelloWorlddsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}


# Test more than limit pipes
@test "Remote: 8(more than limit) pipes" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF           
echo "Hello World" | cat  | cat  | cat  | cat  | cat  | cat  | cat  | cat
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>error:pipinglimitedto8commandsdsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}


# Test built-in cd command
@test "Remote: Built-in cd" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF                
cd /
pwd
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>dsh4>/dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test exit command
@test "Remote: Exit Command" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF                
exit
EOF
    [ "$status" -eq 0 ]
}

# Test quoting
@test "Remote: Quoting" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF                
echo "Hello World"
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>HelloWorlddsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test leading and trailing spaces
@test "Remote: Whitespace Handling" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF                
    echo Test    
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>Testdsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test empty input
@test "Remote: Empty Input" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF                

EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>warning:nocommandsprovideddsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}



















# Basic single pipe test
@test "Remote: Simple Pipe ls | grep dshlib.c" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
ls | grep dshlib.c
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>dshlib.cdsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe with three commands
@test "Remote: Triple Pipe: ls | grep dsh | wc -l" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
ls | grep -w dsh | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>1dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe where first command has no output
@test "Remote: Pipe from empty command: echo '' | grep test" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
echo '' | grep test
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>dsh4>cmdloopreturned0"  # No output from grep

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe with cat and grep
@test "Remote: Pipe with cat and grep: cat dshlib.h | grep '#define'" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
cat dshlib.h | grep "exec_local_cmd_loop"
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>intexec_local_cmd_loop();dsh4>cmdloopreturned0" 

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe to sort, uniq, and wc
@test "Remote: Sort and Count Unique Lines: cat dshlib.h | sort | uniq | wc -l" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
cat dshlib.h | sort | uniq | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>75dsh4>cmdloopreturned0"  

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}




# Pipe with trailing spaces
@test "Remote: Pipe with Trailing Spaces: ls | grep dsh " {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
ls | grep -w dsh      
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>dshdsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}


# Pipe using echo as input
@test "Remote: Echo Pipe: echo 'hello world' | grep hello" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
echo "hello world" | grep hello
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>helloworlddsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}



# Built-in stop-server command
@test "Remote: Built-in stop-server command" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]\004')
    expected_output="socketclientmode:addr:${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT}dsh4>clientrequestedservertostop,stopping...cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}