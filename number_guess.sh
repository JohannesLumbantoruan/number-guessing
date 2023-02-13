#!/bin/bash
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0
USER_ID=0
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
echo "Enter your username:"
read USERNAME
USERNAME_CHECK=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
if [[ $USERNAME_CHECK ]]
then
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  echo $USERNAME_CHECK | while read USERID BAR USER_NAME
  do
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE user_id = $USERID")
    BEST_GAMES=$($PSQL "SELECT MIN(guess_total) FROM games INNER JOIN users USING(user_id) WHERE user_id = $USERID")
    echo "Welcome back, $(echo $USER_NAME | sed -r 's/^ *//g')! You have played $(echo $GAMES_PLAYED | sed -r 's/^ *//g') games, and your best game took $(echo $BEST_GAMES | sed -r 's/^ *//g') guesses."
  done
else
  INSERT_USERNAME=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi
echo "Guess the secret number between 1 and 1000:"
read NUMBER
if [[ ! $NUMBER =~ ^[0-9]+$ ]]
then
  echo "That is not an integer, guess again:"
  read NUMBER
fi
NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
while [ $NUMBER -ne $SECRET_NUMBER ]
do
  if [[ $NUMBER -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read NUMBER
    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
  elif [[ $NUMBER -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read NUMBER
    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
  fi
done
INSERT_DATA=$($PSQL "INSERT INTO games (guess_total, user_id) VALUES ($NUMBER_OF_GUESSES, $USER_ID)")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"