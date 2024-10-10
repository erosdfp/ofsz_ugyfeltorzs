# Planned Data model

## Business process

We have 3 different business processes that we can represent.
1. Assignment, revocation, and change of a bank account under a client, or vice versa.
2. Assignment, revocation, and change of a card under a natural person.
3. Change of relationship between natural persons and their representatives.

```mermaid
erDiagram
    BRIDGE_ACCOUNT_PARTNER {
int asd pk
int partner_key fk
int account_key fk
int activation_date_key fk
int termination_date_key fk
}

BRIDGE_CARD_PARTNER {
int partner_key fk
int card_key fk
int account_key fk

int registration_date_key fk
int activation_date_key fk
int termination_date_key fk
}
DIM_PARTNER {
int partner_key PK
string partner_code
string partner_name
string other_data
}
DIM_ACCOUNT {
int account_key PK
string account_number
string account_type
 }
DIM_CARD {
int card_key PK
string card_number
string card_type
string name_on_card_cover
string card_status
int withdrawal_limit_amount
int withdrawal_limit_occurence
int shopping_limit_amount
int shopping_limit_occurence
date expiration_date

 }
DIM_DATE {
int date_key PK
int year
int month
int day
}

BRIDGE_ACCOUNT_PARTNER }o--|| DIM_PARTNER: has
BRIDGE_ACCOUNT_PARTNER }o--|| DIM_ACCOUNT: associated_with
BRIDGE_ACCOUNT_PARTNER }o--|| DIM_DATE: activated_at
BRIDGE_ACCOUNT_PARTNER }o--|| DIM_DATE: terminated_at

BRIDGE_CARD_PARTNER }o--|| DIM_CARD: has
BRIDGE_CARD_PARTNER}o--|| DIM_PARTNER: has
BRIDGE_CARD_PARTNER }o--|| DIM_ACCOUNT: associated_with
BRIDGE_CARD_PARTNER }o--|| DIM_DATE: registered_at
BRIDGE_CARD_PARTNER }o--|| DIM_DATE: activated_at
BRIDGE_CARD_PARTNER }o--|| DIM_DATE: terminated_at
```

## Known Relationship Problems

1. Foreign key points to an invalid value
    1. Cause: The record with the foreign key was uploaded before the row we're pointing to
    2. Solution: Add the relation to the bridge table. The data will indicate that this row has no data yet. Maybe add
       a missing data flag.
2. Foreign key is null
   1. Cause: Upstream DQ fail.
   2. Solution 1: Send these rows into a separate failure table.
   3. Solution 2: Create a dummy row in the client table for unknown clients. The rows in the bridge table point to
      that client.