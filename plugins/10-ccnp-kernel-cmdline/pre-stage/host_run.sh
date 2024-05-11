#!/bin/bash

CURR_DIR=$(dirname "$(readlink -f "$0")")

CCNP_KERNEL_CMDLINE="ima_policy=tcb ima_hash=sha384 ima_template=ima-cgpath"

cat > "${CURR_DIR}/ccnp-cmdline.sh" << EOF
#!/bin/bash

GRUB_FILE=/etc/default/grub.d/50-cloudimg-settings.cfg

CCNP_KERNEL_CMDLINE="${CCNP_KERNEL_CMDLINE}"
KERNEL_CMDLINE=\$(sed -n 's/[ \t^#]*GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/\1/p' \${GRUB_FILE})
NEW_KERNEL_CMDLINE="\${KERNEL_CMDLINE}"

for PARAMETER in \${CCNP_KERNEL_CMDLINE}
do
    if [ "\${KERNEL_CMDLINE}" != *"\${PARAMETER}"* ]
    then
        NEW_KERNEL_CMDLINE="\${NEW_KERNEL_CMDLINE} \${PARAMETER}"
    fi
done

sed -i "s/[ \t^#]*GRUB_CMDLINE_LINUX_DEFAULT=.*$/\GRUB_CMDLINE_LINUX_DEFAULT=\
\"\${NEW_KERNEL_CMDLINE}\"/" \${GRUB_FILE}

update-grub

EOF

virt-customize -a "${GUEST_IMG}" --run "${CURR_DIR}/ccnp-cmdline.sh"

rm "${CURR_DIR}/ccnp-cmdline.sh"
