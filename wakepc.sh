## wakepc.sh, script used to turn on desktop remotely 

```bash
#!/bin/bash

echo "Sending Wake-on-LAN packet..."
wakeonlan AA:BB:CC:DD:EE:FF

echo "Waiting 20 seconds for system boot..."
sleep 20

echo "System should now be reachable via RDP."

############Make executable#################################

chmod +x wakepc.sh

#############Optional alias############################


alias wakepc="~/wakepc.sh"


