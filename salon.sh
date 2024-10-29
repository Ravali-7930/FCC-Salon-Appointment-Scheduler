#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "Welcome to My Salon, how can I help you?"

  # Retrieve and display service options
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "\nHere are the services available:"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME; do
    echo "$SERVICE_ID) $NAME"
  done

  # Prompt for service selection
  echo -e "\nPlease select the desired service by entering the service ID:"
  read SERVICE_ID_SELECTED

  # Validate the SERVICE_ID_SELECTED input
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ -z $SERVICE_NAME ]]; then
    MAIN_MENU "Please select a valid option for service."
  else
    # Collect customer details
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE

    # Check if customer exists by phone number
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "I don't have a record for that phone number. What's your name?"
      read CUSTOMER_NAME

      # Insert new customer into the database
      INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # Request service time
    echo -e "Please select the service time:"
    read SERVICE_TIME

    # Retrieve CUSTOMER_ID and insert appointment
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Display confirmation
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
