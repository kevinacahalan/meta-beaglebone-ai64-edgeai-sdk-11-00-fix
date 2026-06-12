# edgeai-tidl-models.bbappend  (meta-bbai64-custom)
#
# Ported verbatim from the WORKING j721e-sk fix:
#   https://github.com/kevinacahalan/meta-j721e-sk-edgeai-sdk-11-00-fix
#
# Why this is needed (same root cause as j721e-sk):
#   The stock SDK 11.00 edgeai-tidl-models recipe downloads the model zoo with
#   EDGEAI_SDK_VERSION=11_00_00. The edgeai-gst-apps demos in this SDK actually
#   expect the 11_00_04_00 model zoo, so with the stock models the gallery /
#   demo app launches and immediately exits ("flashes for a split second").
#   This bbappend replaces ONLY do_fetch() to pull the 11_00_04_00 models.
#
# beaglebone-ai64 is a J721E SoC (machine requires j721e.inc), so the base
# recipe's "SOC:j721e = j721e" and COMPATIBLE_MACHINE="j721e|..." both apply,
# and ${SRCREV}/${SOC}/${WORKDIR} come from the unchanged meta-edgeai recipe.
#
# Refs:
#   https://e2e.ti.com/support/processors-group/processors/f/processors-forum/1619144
#   https://e2e.ti.com/support/processors-group/processors/f/processors-forum/1628604
do_fetch() {
    mkdir -p ${WORKDIR}/script
    cd ${WORKDIR}/script

    VERSION="${SRCREV}"

    wget https://raw.githubusercontent.com/TexasInstruments/edgeai-gst-apps/${VERSION}/download_models.sh
    chmod +x ./download_models.sh

    export SOC="${SOC}"
    export EDGEAI_SDK_VERSION=11_00_04_00
    ./download_models.sh --recommended

    # Restore the stock value so later tasks don't inherit the override.
    export EDGEAI_SDK_VERSION=11_00_00
}
