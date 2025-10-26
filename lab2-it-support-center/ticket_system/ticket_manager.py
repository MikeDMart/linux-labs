#!/usr/bin/env python3
"""
Enhanced IT Support Ticket Management System
With rich CLI interface and comprehensive reporting
"""

import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime, timedelta
import random
import string
import sys
import json
from typing import Dict, List, Optional
import argparse
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import print as rprint

console = Console()

class EnhancedTicketManager:
    def __init__(self, db_config):
        try:
            self.conn = psycopg2.connect(**db_config)
            self.cursor = self.conn.cursor(cursor_factory=RealDictCursor)
            console.print("✅ [green]Conectado a la base de datos[/green]")
        except Exception as e:
            console.print(f"❌ [red]Error conectando a la base de datos: {e}[/red]")
            raise

    def generate_ticket_number(self) -> str:
        """Generate unique ticket number with prefix and timestamp"""
        prefix = "TKT"
        timestamp = datetime.now().strftime("%Y%m%d")
        random_suffix = ''.join(random.choices(string.digits, k=4))
        return f"{prefix}-{timestamp}-{random_suffix}"

    def calculate_sla_deadline(self, priority: str) -> datetime:
        """Calculate SLA deadline based on priority"""
        now = datetime.now()
        sla_times = {
            'critical': timedelta(hours=2),
            'high': timedelta(hours=4),
            'medium': timedelta(hours=8),
            'low': timedelta(days=1)
        }
        return now + sla_times.get(priority, timedelta(days=1))

    def create_ticket(self, title: str, description: str, category: str,
                     priority: str, requester_id: int) -> Dict:
        """Create a new support ticket with SLA tracking"""
        ticket_number = self.generate_ticket_number()
        sla_deadline = self.calculate_sla_deadline(priority)

        query = """
            INSERT INTO tickets (ticket_number, title, description, category,
                               priority, requester_id, status)
            VALUES (%s, %s, %s, %s, %s, %s, 'open')
            RETURNING id, ticket_number
        """

        self.cursor.execute(query, (ticket_number, title, description,
                                  category, priority, requester_id))
        result = self.cursor.fetchone()
        self.conn.commit()

        return result

    def assign_ticket(self, ticket_id: int, technician_id: int) -> Optional[Dict]:
        """Assign ticket to a technician"""
        query = """
            UPDATE tickets
            SET assigned_to = %s, status = 'in_progress', 
                updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
            RETURNING ticket_number, assigned_to
        """

        self.cursor.execute(query, (technician_id, ticket_id))
        result = self.cursor.fetchone()
        self.conn.commit()

        return result

    def add_comment(self, ticket_id: int, user_id: int, comment: str,
                   is_internal: bool = False) -> Optional[Dict]:
        """Add comment to ticket with optional internal flag"""
        query = """
            INSERT INTO ticket_comments (ticket_id, user_id, comment, is_internal)
            VALUES (%s, %s, %s, %s)
            RETURNING id, created_at
        """

        self.cursor.execute(query, (ticket_id, user_id, comment, is_internal))
        result = self.cursor.fetchone()
        
        # Update ticket's updated_at
        self.cursor.execute(
            "UPDATE tickets SET updated_at = CURRENT_TIMESTAMP WHERE id = %s", 
            (ticket_id,)
        )
        self.conn.commit()

        return result

    def update_ticket_status(self, ticket_id: int, new_status: str,
                           satisfaction_rating: int = None) -> Optional[Dict]:
        """Update ticket status and calculate resolution metrics"""
        query = """
            UPDATE tickets
            SET status = %s, updated_at = CURRENT_TIMESTAMP
            WHERE id = %s
            RETURNING ticket_number
        """

        if new_status == 'closed':
            # Calculate resolution time and set closed timestamp
            query = """
                UPDATE tickets
                SET status = %s, closed_at = CURRENT_TIMESTAMP,
                    resolution_time = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at))/60,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = %s
                RETURNING ticket_number, resolution_time
            """
            self.cursor.execute(query, (new_status, ticket_id))
        else:
            self.cursor.execute(query, (new_status, ticket_id))

        result = self.cursor.fetchone()
        self.conn.commit()

        return result

    def get_ticket_details(self, ticket_id: int) -> Optional[Dict]:
        """Get comprehensive ticket details with comments and user info"""
        query = """
            SELECT t.*, 
                   r.full_name as requester_name, r.email as requester_email,
                   r.department as requester_department,
                   a.full_name as assigned_name, a.email as assigned_email
            FROM tickets t
            LEFT JOIN users r ON t.requester_id = r.id
            LEFT JOIN users a ON t.assigned_to = a.id
            WHERE t.id = %s
        """

        self.cursor.execute(query, (ticket_id,))
        ticket = self.cursor.fetchone()

        if ticket:
            # Get all comments
            self.cursor.execute("""
                SELECT c.*, u.full_name as user_name, u.role as user_role
                FROM ticket_comments c
                JOIN users u ON c.user_id = u.id
                WHERE c.ticket_id = %s
                ORDER BY c.created_at
            """, (ticket_id,))
            ticket['comments'] = self.cursor.fetchall()

        return ticket

    def list_tickets(self, status: str = None, priority: str = None, 
                    assigned_to: int = None, limit: int = 50) -> List[Dict]:
        """List tickets with advanced filtering and sorting"""
        query = """
            SELECT t.id, t.ticket_number, t.title, t.category, t.priority, t.status,
                   t.created_at,
                   r.full_name as requester_name, 
                   a.full_name as assigned_name
            FROM tickets t
            LEFT JOIN users r ON t.requester_id = r.id
            LEFT JOIN users a ON t.assigned_to = a.id
            WHERE 1=1
        """
        params = []

        if status:
            query += " AND t.status = %s"
            params.append(status)

        if priority:
            query += " AND t.priority = %s"
            params.append(priority)

        if assigned_to:
            query += " AND t.assigned_to = %s"
            params.append(assigned_to)

        query += " ORDER BY t.priority DESC, t.created_at DESC LIMIT %s"
        params.append(limit)

        self.cursor.execute(query, params)
        return self.cursor.fetchall()

    def get_ticket_statistics(self) -> Dict:
        """Get comprehensive ticket statistics and metrics"""
        stats = {}

        # Basic counts
        self.cursor.execute("SELECT COUNT(*) as total FROM tickets")
        stats['total_tickets'] = self.cursor.fetchone()['total']

        # Status distribution
        self.cursor.execute("""
            SELECT status, COUNT(*) as count
            FROM tickets
            GROUP BY status
            ORDER BY count DESC
        """)
        stats['by_status'] = {row['status']: row['count'] for row in self.cursor.fetchall()}

        # Priority distribution
        self.cursor.execute("""
            SELECT priority, COUNT(*) as count
            FROM tickets
            GROUP BY priority
            ORDER BY 
                CASE priority 
                    WHEN 'critical' THEN 1
                    WHEN 'high' THEN 2
                    WHEN 'medium' THEN 3
                    WHEN 'low' THEN 4
                END
        """)
        stats['by_priority'] = {row['priority']: row['count'] for row in self.cursor.fetchall()}

        # Category distribution
        self.cursor.execute("""
            SELECT category, COUNT(*) as count
            FROM tickets
            GROUP BY category
            ORDER BY count DESC
        """)
        stats['by_category'] = {row['category']: row['count'] for row in self.cursor.fetchall()}

        return stats

    def display_tickets_table(self, tickets: List[Dict]):
        """Display tickets in a rich formatted table"""
        if not tickets:
            console.print("📭 [yellow]No hay tickets que mostrar[/yellow]")
            return

        table = Table(title="🎫 Support Tickets", show_header=True, header_style="bold magenta")
        
        table.add_column("ID", style="dim", width=6)
        table.add_column("Ticket #", style="cyan", width=18)
        table.add_column("Title", width=30)
        table.add_column("Category", style="green")
        table.add_column("Priority", style="red")
        table.add_column("Status", style="yellow")
        table.add_column("Requester", style="blue")
        table.add_column("Created", style="dim", width=12)

        for ticket in tickets:
            priority_color = {
                'critical': 'red',
                'high': 'yellow',
                'medium': 'blue',
                'low': 'green'
            }.get(ticket['priority'], 'white')
            
            status_icon = {
                'open': '🟡',
                'in_progress': '🔵',
                'pending': '🟠',
                'resolved': '🟢',
                'closed': '⚫'
            }.get(ticket['status'], '⚪')

            created_time = ticket['created_at'].strftime('%m/%d %H:%M') if ticket['created_at'] else 'N/A'

            table.add_row(
                str(ticket['id']),
                ticket['ticket_number'],
                ticket['title'][:28] + "..." if len(ticket['title']) > 28 else ticket['title'],
                ticket['category'],
                f"[{priority_color}]{ticket['priority']}[/{priority_color}]",
                f"{status_icon} {ticket['status']}",
                ticket['requester_name'] or 'Unknown',
                created_time
            )

        console.print(table)

    def display_statistics(self, stats: Dict):
        """Display comprehensive statistics in rich format"""
        # Overall stats
        overall_panel = Panel(
            f"📊 Total Tickets: [bold cyan]{stats['total_tickets']}[/bold cyan]\n"
            f"📈 By Status: {stats['by_status']}\n"
            f"🚨 By Priority: {stats['by_priority']}\n"
            f"📁 By Category: {stats['by_category']}",
            title="Overall Statistics",
            border_style="green"
        )
        console.print(overall_panel)

    def close(self):
        """Close database connection"""
        self.cursor.close()
        self.conn.close()

def main():
    """Enhanced CLI interface with rich formatting"""
    parser = argparse.ArgumentParser(description="IT Support Ticket Management System")
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Create ticket command
    create_parser = subparsers.add_parser('create', help='Create a new ticket')
    create_parser.add_argument('title', help='Ticket title')
    create_parser.add_argument('description', help='Ticket description')
    create_parser.add_argument('category', choices=['hardware', 'software', 'network', 'account', 'other'])
    create_parser.add_argument('priority', choices=['low', 'medium', 'high', 'critical'])
    create_parser.add_argument('requester_id', type=int, help='Requester user ID')
    
    # List tickets command
    list_parser = subparsers.add_parser('list', help='List tickets')
    list_parser.add_argument('--status', help='Filter by status')
    list_parser.add_argument('--priority', help='Filter by priority')
    list_parser.add_argument('--limit', type=int, default=20, help='Number of tickets to show')
    
    # Statistics command
    subparsers.add_parser('stats', help='Show ticket statistics')
    
    # Get ticket details
    get_parser = subparsers.add_parser('get', help='Get ticket details')
    get_parser.add_argument('ticket_id', type=int, help='Ticket ID')
    
    # Assign ticket command
    assign_parser = subparsers.add_parser('assign', help='Assign ticket to technician')
    assign_parser.add_argument('ticket_id', type=int, help='Ticket ID')
    assign_parser.add_argument('technician_id', type=int, help='Technician user ID')
    
    args = parser.parse_args()
    
    # Database configuration - USANDO TU PASSWORD
    db_config = {
        'host': 'localhost',
        'database': 'it_support',
        'user': 'itsupport_user',
        'password': '12345678'  # Tu password real
    }
    
    tm = EnhancedTicketManager(db_config)
    
    try:
        if args.command == 'create':
            result = tm.create_ticket(
                args.title, args.description, args.category, 
                args.priority, args.requester_id
            )
            console.print(Panel(
                f"✅ [bold green]Ticket Created Successfully![/bold green]\n"
                f"🎫 Ticket Number: [bold cyan]{result['ticket_number']}[/bold cyan]\n"
                f"📝 Title: {args.title}",
                title="New Ticket",
                border_style="green"
            ))
            
        elif args.command == 'list':
            tickets = tm.list_tickets(
                status=args.status,
                priority=args.priority,
                limit=args.limit
            )
            tm.display_tickets_table(tickets)
            
        elif args.command == 'stats':
            stats = tm.get_ticket_statistics()
            tm.display_statistics(stats)
            
        elif args.command == 'get':
            ticket = tm.get_ticket_details(args.ticket_id)
            if ticket:
                # Format assigned name
                assigned_name = ticket['assigned_name'] or 'Unassigned'
                
                console.print(Panel(
                    f"🎫 [bold]{ticket['ticket_number']}[/bold] - {ticket['title']}\n"
                    f"📁 Category: {ticket['category']} | 🚨 Priority: {ticket['priority']}\n"
                    f"📊 Status: {ticket['status']}\n"
                    f"👤 Requester: {ticket['requester_name']} ({ticket['requester_department']})\n"
                    f"🛠️ Assigned: {assigned_name}\n"
                    f"📝 Description: {ticket['description']}",
                    title="Ticket Details",
                    border_style="blue"
                ))
            else:
                console.print("[red]❌ Ticket not found[/red]")
                
        elif args.command == 'assign':
            result = tm.assign_ticket(args.ticket_id, args.technician_id)
            if result:
                console.print(Panel(
                    f"✅ [bold green]Ticket assigned successfully![/bold green]\n"
                    f"🎫 Ticket: {result['ticket_number']}\n"
                    f"👤 Assigned to technician ID: {result['assigned_to']}",
                    title="Ticket Assignment",
                    border_style="green"
                ))
            else:
                console.print("[red]❌ Failed to assign ticket[/red]")
                
        else:
            parser.print_help()
            
    except Exception as e:
        console.print(f"[red]❌ Error: {str(e)}[/red]")
    finally:
        tm.close()

if __name__ == "__main__":
    main()
