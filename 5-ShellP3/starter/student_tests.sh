#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

@test "Example: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

#!/usr/bin/env bats

# Test basic command execution
@test "Basic Command Execution" {
    run "./dsh" <<EOF                
echo Hello, World!
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="Hello,World!dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test pipes
@test "Pipes" {
    run "./dsh" <<EOF                
ls | grep dshlib.c
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dshlib.cdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test multiple pipes
@test "Multiple Pipes" {
    run "./dsh" <<EOF                
echo "Hello World" | tr " " "\n" | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="2dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test built-in cd command
@test "Built-in cd" {
    run "./dsh" <<EOF                
cd /
pwd
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="/dsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test exit command
@test "Exit Command" {
    run "./dsh" <<EOF                
exit
EOF
    [ "$status" -eq 0 ]
}

# Test quoting
@test "Quoting" {
    run "./dsh" <<EOF                
echo "Hello World"
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="HelloWorlddsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test leading and trailing spaces
@test "Whitespace Handling" {
    run "./dsh" <<EOF                
    echo Test    
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="Testdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test empty input
@test "Empty Input" {
    run "./dsh" <<EOF                

EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>warning:nocommandsprovideddsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Test invalid command
@test "Invalid Command" {
    run "./dsh" <<EOF                
asdfghjkl
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="execvpfailed:Nosuchfileordirectorydsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}



















# Basic single pipe test
@test "Simple Pipe ls | grep dshlib.c" {
    run "./dsh" <<EOF
ls | grep dshlib.c
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dshlib.cdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe with three commands
@test "Triple Pipe: ls | grep dsh | wc -l" {
    run "./dsh" <<EOF
ls | grep -w dsh | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    
    # The expected output depends on the number of lines matching "dsh"
    expected_output="1dsh3>dsh3>cmdloopreturned0" # Adjust this based on actual output

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe where first command has no output
@test "Pipe from empty command: echo '' | grep test" {
    run "./dsh" <<EOF
echo '' | grep test
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dsh3>dsh3>cmdloopreturned0"  # No output from grep

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe with cat and grep
@test "Pipe with cat and grep: cat dshlib.h | grep '#define'" {
    run "./dsh" <<EOF
cat dshlib.h | grep "exec_local_cmd_loop"
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    
    expected_output="intexec_local_cmd_loop();dsh3>dsh3>cmdloopreturned0" 

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe to sort, uniq, and wc
@test "Sort and Count Unique Lines: cat dshlib.h | sort | uniq | wc -l" {
    run "./dsh" <<EOF
cat dshlib.h | sort | uniq | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    
    expected_output="74dsh3>dsh3>cmdloopreturned0"  

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}

# Pipe with invalid command in middle
@test "Invalid Command in Pipe: ls | nonexistentcommand | wc -l" {
    run "./dsh" <<EOF
ls | nonexistentcommand | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    
    expected_output="execvpfailed:Nosuchfileordirectory0dsh3>dsh3>cmdloopreturned0"  # Adjust error message if needed

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ] # Expect failure
}



# Pipe with trailing spaces
@test "Pipe with Trailing Spaces: ls | grep dsh " {
    run "./dsh" <<EOF
ls | grep -w dsh      
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="dshdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}


# Pipe using echo as input
@test "Echo Pipe: echo 'hello world' | grep hello" {
    run "./dsh" <<EOF
echo "hello world" | grep hello
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="helloworlddsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
    [ "$status" -eq 0 ]
}
