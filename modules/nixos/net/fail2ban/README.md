### Using `fail2ban`:

```nushell
sudo fail2ban-client status                        # Check the status of jails.
sudo fail2ban-client status sshd                   # Inspect a specific jail.
sudo fail2ban-client set sshd unbanip <IP_ADDRESS> # Unban an IP address.
```
