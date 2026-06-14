# BBAI64 display handoff fix.
#
# Keep the stock j721e-sk service model (getty enabled, emptty started then stopped
# by edgeai-launcher). The BBAI64-specific issue is that linux-bb.org/fbcon leaves
# stale framebuffer contents unless the GUI starts after the real psplash process is
# gone and the framebuffer has been repainted once.
#
# The files in edgeai-init/ override upstream files already listed in SRC_URI.
# No psplash kill, no fb0 dd, no fbcon unbind, no systemd masks.

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
