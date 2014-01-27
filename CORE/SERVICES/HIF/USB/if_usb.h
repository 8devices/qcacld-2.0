/*
 * Copyright (c) 2013-2014 The Linux Foundation. All rights reserved.
 *
 * Previously licensed under the ISC license by Qualcomm Atheros, Inc.
 *
 *
 * Permission to use, copy, modify, and/or distribute this software for
 * any purpose with or without fee is hereby granted, provided that the
 * above copyright notice and this permission notice appear in all
 * copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
 * WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
 * DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
 * PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

/*
 * This file was originally distributed by Qualcomm Atheros, Inc.
 * under proprietary terms before Copyright ownership was assigned
 * to the Linux Foundation.
 */
#ifndef __ATH_USB_H__
#define __ATH_USB_H__

#include <linux/version.h>
#if LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 26)
#include <asm/semaphore.h>
#else
#include <linux/semaphore.h>
#endif
#include <linux/interrupt.h>

/*
 * There may be some pending tx frames during platform suspend.
 * Suspend operation should be delayed until those tx frames are
 * transfered from the host to target. This macro specifies how
 * long suspend thread has to sleep before checking pending tx
 * frame count.
 */
#define OL_ATH_TX_DRAIN_WAIT_DELAY     50	/* ms */
/*
 * Wait time (in unit of OL_ATH_TX_DRAIN_WAIT_DELAY) for pending
 * tx frame completion before suspend. Refer: hif_pci_suspend()
 */
#define OL_ATH_TX_DRAIN_WAIT_CNT       10

#define CONFIG_COPY_ENGINE_SUPPORT	/* TBDXXX: here for now */
#define ATH_DBG_DEFAULT   0
#include <osdep.h>
#include <ol_if_athvar.h>
#include <athdefs.h>
#include "osapi_linux.h"
#include "hif.h"
struct hif_usb_softc {
	/* For efficiency, should be first in struct */
	struct device *dev;
	struct usb_dev *pdev;
	struct _NIC_DEV aps_osdev;
	struct ol_softc *ol_sc;
	/*
	 * Guard changes to Target HW state and to software
	 * structures that track hardware state.
	 */
	adf_os_spinlock_t target_lock;

	HIF_DEVICE *hif_device;

	u16 devid;
	struct targetdef_s *targetdef;
	struct hostdef_s *hostdef;
};

/* Function to set the TXRX handle in the ol_sc context */
void hif_init_pdev_txrx_handle(void *ol_sc, void *txrx_handle);
void hif_disable_isr(void *ol_sc);
void hif_reset_soc(void *ol_sc);
void hif_init_adf_ctx(adf_os_device_t adf_dev, void *ol_sc);

#ifndef REMOVE_PKT_LOG
extern int pktlogmod_init(void *context);
extern void pktlogmod_exit(void *context);
#endif

#endif /* __ATH_USB_H__ */
