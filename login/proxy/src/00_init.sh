#!/bin/bash

if [ ! -z "$THEIAPASSWORD" ]; then
    addauth $THEIAUSER $THEIAPASSWORD
fi    
