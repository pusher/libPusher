#!/bin/bash
tail -n +4 Sample\ iOS/Constants.h.example > Sample\ iOS/Constants.h
echo \#define PUSHER_APP_ID @\"$(env | grep PUSHER_APP_ID | cut -d "=" -f 2)\" >> Sample\ iOS/Constants.h
echo \#define PUSHER_API_KEY @\"$(env | grep PUSHER_API_KEY | cut -d "=" -f 2)\" >> Sample\ iOS/Constants.h
echo \#define PUSHER_API_SECRET @\"$(env | grep PUSHER_API_SECRET | cut -d "=" -f 2)\" >> Sample\ iOS/Constants.h
