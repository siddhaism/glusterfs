#!/bin/bash

. $(dirname $0)/../include.rc
. $(dirname $0)/../volume.rc

function get-task-status()
{
        $CLI $COMMAND | grep -o $PATTERN
        if [ ${PIPESTATUS[0]} -ne 0 ];
        then
                return 1
        fi
        return 0
}

cleanup;

TEST glusterd
TEST pidof glusterd

TEST $CLI volume create $V0 $H0:$B0/${V0}{1,2,3,4}
TEST $CLI volume start $V0
TEST ! $CLI volume remove-brick $V0 $H0:$B0/${V0}1
TEST $CLI volume remove-brick $V0 $H0:$B0/${V0}2 force
TEST $CLI volume remove-brick $V0 $H0:$B0/${V0}3 start

EXPECT_WITHIN 10 "completed" remove_brick_status_completed_field "$V0" \
"$H0:$B0/${V0}3"

TEST $CLI volume remove-brick $V0 $H0:$B0/${V0}3 commit
TEST killall glusterd
TEST glusterd

cleanup
