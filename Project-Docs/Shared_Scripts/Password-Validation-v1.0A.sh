#!/bin/bash

echo "Validate that your password is secure"
read -p "Enter 'skip' to skip this section, 'yes' to confirm your password is secure, or 'test' to check your password's security: " response

if [[ "$response" == "skip" ]]; then
  echo "Skipping password validation"
elif [[ "$response" == "yes" ]]; then
  echo "Thank you for validating this step."
elif [[  "$response" == "test" ]]; then
  # Check if the password meets the minimum security requirements
  password_meets=false

  while [[ "$password_meets" == false ]]; do
    read -s -p "Enter your password to check its security: " password
    echo

    # Check password meets requirements
    if [[ ${#password} -lt 8 ]] || ! [[ $password =~ [A-Z] ]] || ! [[ $password =~ [a-z] ]] || ! [[ $password =~ [0-9] ]] || ! [[ $password =~ [^a-zA-Z0-9] ]]; then
      echo "This password does not meet minimum safety requirements. Please try again with a password that has at least one capital letter, one lower case letter, one special character, one number, and is at least eight characters long."
    else
      echo "Your password meets the minimum security requirements."
      password_meets=true
    fi
  done
fi

echo "Continuing to the next section of the script"

echo "Passed"
