#!/usr/bin/env bash

KB=1024
MB=$((1024 * KB))
GB=$((1024 * MB))

threads=( 1 2 4 8 )
#sizes=( $((1 * KB)) $((96 * KB)) $((3 * MB)) )
sizes=( $((1 * KB)) )
db_size=$(( 3 * GB ))

for (( i = 0; i < ${#threads[@]}; i++ ))
do
  for (( j = 0; j < ${#sizes[@]}; j++ ))
  do
    num=$(( ( db_size + sizes[j] - 1 ) / sizes[j] ))

    mkdir ./stats_h_${threads[i]}t_${sizes[j]}b
    {
    case "$RBENCH_DEV_MODE" in
        nvm)
            sudo rm -rf /opt/rocks/*
        ;;
        posix)
            sudo rm -rf /mnt/posix/rocks/*
        ;;
    esac

    sudo -E RBENCH_DEV_NAME="nvme0n1" RBENCH_NUM=$num RBENCH_VALUE_SIZE=${sizes[j]} RBENCH_THREADS=${threads[i]} RBENCH_MAPPING=1 RBENCH_HEIGHT=1 ./run.sh

    case "$RBENCH_DEV_MODE" in
        nvm)
            sudo cp /opt/rocks/nvme0n1_nvm/LOG* ./stats_h_${threads[i]}t_${sizes[j]}b
        ;;
        posix)
            sudo cp /mnt/posix/rocks/LOG* ./stats_h_${threads[i]}t_${sizes[j]}b
        ;;
    esac
    } 2>&1 | tee ./stats_h_${threads[i]}t_${sizes[j]}b/output

    mkdir ./stats_v_${threads[i]}t_${sizes[j]}b
    {
    case "$RBENCH_DEV_MODE" in
        nvm)
            sudo rm -rf /opt/rocks/*
        ;;
        posix)
            sudo rm -rf /mnt/posix/rocks/*
        ;;
    esac

    sudo -E RBENCH_DEV_NAME="nvme0n1" RBENCH_NUM=$num RBENCH_VALUE_SIZE=${sizes[j]} RBENCH_THREADS=${threads[i]} RBENCH_MAPPING=2 RBENCH_HEIGHT=8 ./run.sh

    case "$RBENCH_DEV_MODE" in
        nvm)
            sudo cp /opt/rocks/nvme0n1_nvm/LOG* ./stats_v_${threads[i]}t_${sizes[j]}b
        ;;
        posix)
            sudo cp /mnt/posix/rocks/LOG* ./stats_v_${threads[i]}t_${sizes[j]}b
        ;;
    esac
    } 2>&1 | tee ./stats_v_${threads[i]}t_${sizes[j]}b/output
  done
done
