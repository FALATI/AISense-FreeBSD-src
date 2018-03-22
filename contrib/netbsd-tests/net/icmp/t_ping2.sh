#	$NetBSD: t_ping2.sh,v 1.4 2010/12/30 16:58:07 pooka Exp $
#
# Copyright (c) 2010 The NetBSD Foundation, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

netserver=\
"rump_server -lrumpnet -lrumpnet_net -lrumpnet_netinet -lrumpnet_shmif"

atf_test_case basic cleanup
basic_head()
{

	atf_set "descr" "Checks that a simple ping works"
}

docfg ()
{

	sock=${1}
	addr=${2}

	atf_check -s exit:0 \
	    env RUMP_SERVER=${sock} rump.ifconfig shmif0 create
	atf_check -s exit:0 \
	    env RUMP_SERVER=${sock} rump.ifconfig shmif0 linkstr bus
	atf_check -s exit:0 \
	    env RUMP_SERVER=${sock} rump.ifconfig shmif0 inet ${addr}
}

basic_body()
{

	atf_check -s exit:0 ${netserver} unix://commsock1
	atf_check -s exit:0 ${netserver} unix://commsock2

	docfg unix://commsock1 1.2.3.4
	docfg unix://commsock2 1.2.3.5

	atf_check -s exit:0 -o ignore \
	    env RUMP_SERVER=unix://commsock1 rump.ping -n -c 1 1.2.3.5
	atf_check -s exit:0 -o ignore \
	    env RUMP_SERVER=unix://commsock2 rump.ping -n -c 1 1.2.3.5
}

basic_cleanup()
{

	env RUMP_SERVER=unix://commsock1 rump.halt
	env RUMP_SERVER=unix://commsock2 rump.halt
}

atf_init_test_cases()
{

	atf_add_test_case basic
}
