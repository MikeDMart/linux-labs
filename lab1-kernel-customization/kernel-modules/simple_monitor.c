/*
 * Simple System Monitor Kernel Module
 * Safe version for kernel 6.1.85
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/mm.h>

#define MODULE_NAME "simple_monitor"

static struct proc_dir_entry *proc_entry;

static int monitor_show(struct seq_file *m, void *v)
{
    struct sysinfo si;
    unsigned long total_ram, free_ram, used_ram;
    
    si_meminfo(&si);
    
    // Convertir a MB de forma segura
    total_ram = (si.totalram * si.mem_unit) >> 20;  // / 1024 / 1024
    free_ram = (si.freeram * si.mem_unit) >> 20;
    used_ram = total_ram - free_ram;
    
    seq_printf(m, "=== System Monitor ===\n");
    seq_printf(m, "Memory Usage:\n");
    seq_printf(m, "  Total RAM: %lu MB\n", total_ram);
    seq_printf(m, "  Used RAM:  %lu MB\n", used_ram);
    seq_printf(m, "  Free RAM:  %lu MB\n", free_ram);
    
    if (total_ram > 0) {
        seq_printf(m, "  Usage:     %lu%%\n", (used_ram * 100) / total_ram);
    } else {
        seq_printf(m, "  Usage:     N/A\n");
    }
    
    return 0;
}

static int monitor_open(struct inode *inode, struct file *file)
{
    return single_open(file, monitor_show, NULL);
}

static const struct proc_ops monitor_ops = {
    .proc_open    = monitor_open,
    .proc_read    = seq_read,
    .proc_lseek   = seq_lseek,
    .proc_release = single_release,
};

static int __init monitor_init(void)
{
    // Crear entrada en /proc
    proc_entry = proc_create(MODULE_NAME, 0444, NULL, &monitor_ops);
    if (!proc_entry) {
        pr_err("Failed to create /proc/%s\n", MODULE_NAME);
        return -ENOMEM;
    }
    
    pr_info("Simple Monitor module loaded successfully\n");
    printk(KERN_INFO "Simple Monitor: System monitor module initialized\n");
    return 0;
}

static void __exit monitor_exit(void)
{
    if (proc_entry) {
        proc_remove(proc_entry);
    }
    pr_info("Simple Monitor module unloaded\n");
    printk(KERN_INFO "Simple Monitor: Module removed\n");
}

module_init(monitor_init);
module_exit(monitor_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Lab Student");
MODULE_DESCRIPTION("Simple system monitoring kernel module");
MODULE_VERSION("1.0");
