#!/bin/bash
# This script should use AWS CLI to query the latest Python solution stack.
# You will need to have AWS CLI installed and configured with the necessary permissions.

# For Python 3.9 as an example
LATEST_STACK=$(aws elasticbeanstalk list-available-solution-stacks --query "SolutionStacks[?contains(@, 'running Python 3.9')]|[0]" --output text)

echo "{\"latest_solution_stack_name\":\"$LATEST_STACK\"}"
