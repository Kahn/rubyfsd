# rubyfsd
An FSD server implementation in Ruby.

## Disclaimer
* This is an educational project. I am not affiliated with VATSIM in any way. Use this software at your own risk.

## About
* Based on the VATSIM FSD protocol.
* Known to support VRC, swift pilot client, xPilot observer towerview, and TWRTrainer.
* Known to NOT work with vSTARS, vERAM, or normal xPilot/vPilot connections.
* Does NOT implement the authentication challenge VATSIM servers force upon clients, nor does it support replying to authentication requests sent by unsupported clients.
* Does NOT implement any type of user authentication. Anyone with a supported FSD client can connect with full privileges!

## Feature List
* Simultaneous pilot, ATC, and sweatbox trainer connections
* Visibility ranges
* Flightplan filing and amendments
* Text messages: Frequency, direct, ATC channel, and broadcast
* METAR requests

## Usage
* Dockerfile is included. No special configuration is needed; create an image then run a container with TCP ports 6809 and 6820 exposed.
* Running without docker will require installing ruby and the gem dependencies listed in the Dockerfile.
