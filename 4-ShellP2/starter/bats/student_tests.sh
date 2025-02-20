#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

@test "Example: check ls runs without errors" {
    run "../dsh" <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}


@test "Built-in: cd with no arguments" {
    run "../dsh" <<EOF
    cd
    pwd
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    # expected_output=$(pwd cmd loop returned 0 | tr -d '[:space:]')
    expected_output=$(echo "$(pwd)dsh2>dsh2>dsh2>cmd loop returned 0" | tr -d '[:space:]')

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    # echo "Expected Output: $expected_output"
    echo "${stripped_output} -> ${expected_output}"    
    [ "$stripped_output" = "$expected_output" ]
}

@test "Built-in: cd to valid directory" {
    run "../dsh" <<EOF
    mkdir -p ./tmp
    cd ./tmp
    pwd
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    # expected_output="/tmp"
    expected_output=$(echo "$(pwd)/tmpdsh2>dsh2>dsh2>dsh2>cmd loop returned 0" | tr -d '[:space:]')
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    [ "$stripped_output" = "$expected_output" ]
}

@test "Built-in: cd to invalid directory" {
    run "../dsh" <<EOF
    cd /nonexistent_dir
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output=$(echo "cd failed: No such file or directory dsh2> dsh2> cmd loop returned 0" | tr -d '[:space:]')
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    [ "$stripped_output" = "$expected_output" ]
}

@test "Built-in: exit command" {
    run "../dsh" <<EOF
    exit
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output}"
    [ "$status" -eq 0 ]
}

@test "External command: ls" {
    run "../dsh" <<EOF
    ls
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output}"
    echo "$output" | grep -q "dsh"
}

@test "External command: echo with spaces" {
    run "../dsh" <<EOF
    echo "hello   world"
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output=$(echo "hello   world dsh2>dsh2>cmdloopreturned0" | tr -d '[:space:]')
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    [ "$stripped_output" = "$expected_output" ]
}

@test "External command: unknown command" {
    run "../dsh" <<EOF
    nonexistentcmd
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output}"
    echo "$output" | grep -q "Execution failed"
}

@test "Command: empty input" {
    run "../dsh" <<EOF
    
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output=$(echo "dsh2>dsh2>cmdloopreturned0" | tr -d '[:space:]')
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output}"
    [ "$stripped_output" = "$expected_output" ]
}

@test "Built-in: extra credit dragon command" {
skip
    run "../dsh" <<EOF
    dragon
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output}"
    echo "$output" | grep -q "BI_CMD_DRAGON"
}