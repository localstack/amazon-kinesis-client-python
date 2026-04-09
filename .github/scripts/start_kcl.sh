#!/bin/bash
set -e
set -o pipefail

chmod +x .github/resources/github_workflow.properties
chmod +x samples/sample_kclpy_app.py

if [[ "$RUNNER_OS" == "macOS" ]]; then
  brew install coreutils
  KCL_COMMAND=$(amazon_kclpy_helper.py --print_command --java $(which java) --properties .github/resources/github_workflow.properties)
  gtimeout $RUN_TIME_SECONDS $KCL_COMMAND 2>&1 | tee kcl_output.log  || [ $? -eq 124 ]
elif [[ "$RUNNER_OS" == "Linux" || "$RUNNER_OS" == "Windows" ]]; then
  KCL_COMMAND=$(amazon_kclpy_helper.py --print_command --java $(which java) --properties .github/resources/github_workflow.properties)
  timeout $RUN_TIME_SECONDS $KCL_COMMAND 2>&1 | tee kcl_output.log || [ $? -eq 124 ]
else
  echo "Unknown OS: $RUNNER_OS"
  exit 1
fi

echo "==========ERROR LOGS=========="
grep -i error kcl_output.log || echo "No errors found in logs"