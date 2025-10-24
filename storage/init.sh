#!/bin/sh

USER_FILE="/etc/samba/smbusers"

# Restaurer les utilisateurs Samba s'ils n'existent pas
if [ -f "$USER_FILE" ]; then
  while IFS= read -r line; do
    username=$(echo "$line" | cut -d':' -f1)
    password=$(echo "$line" | cut -d':' -f2)
    if ! pdbedit -L | grep -q "^$username:"; then
      adduser -D -H -G users "$username"
      usermod -aG smb "$username"  # Ajouter l'utilisateur au groupe smb
      echo "$username:$password" | chpasswd
      (echo "$password"; echo "$password") | smbpasswd -s -a "$username"
    fi
  done < "$USER_FILE"
fi

# Lancer le processus smbd
exec /usr/sbin/smbd -FS </dev/null
