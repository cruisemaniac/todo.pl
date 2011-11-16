#!/usr/bin/perl


#A To-Do management CLI-Script based on the lines of Gina Trapani's Todo.txt
#It uses a folder called todo.pl in Dropbox to keep the todo items synced across computers.

#Things to note:
#1. Add / delete / mark as done / list tasks.
#2. Modifying tasks still not implemented.

use strict;
use warnings;
use Cwd;
use Data::Dumper;
use File::Spec;


#Debug mode: 
#	0 - No debug
#	1 - Verbose
#	2 - debug
my $PRINTVERBOSE = 0;
#Fill this string with whatever directory you want your todo files to be. 
#Leaving it blank will put the todo.txt and done.txt into the same folder as your perl script
my $TODODIR = "";

my @clargs = @ARGV;

if($PRINTVERBOSE == 2)
{
	print "@clargs " . scalar @clargs. "\n";
}


parseArgs(@clargs);

sub parseArgs
{
	my @args = @_;
	if($PRINTVERBOSE == 2)
	{
		print "\nInside parseArgs: @args\n";
	}
	my $cmdarg1 = shift(@args);
	
	if (defined $cmdarg1)
	{
		if($cmdarg1 eq "a" or $cmdarg1 eq "add")
		{
			addTasks(@args);
		}
		
		elsif($cmdarg1 eq "l" or $cmdarg1 eq "list")
		{
			listTasks(@args);
		}
		
		elsif($cmdarg1 eq "x" or $cmdarg1 eq "delete")
		{
			deleteTasks(@args);
		}
		elsif($cmdarg1 eq "d" or $cmdarg1 eq "done")
		{
			doneTasks(@args);
		}
		else
		{
			printHelp();
		}
	}
	else
	{
		printHelp();
	}
	
	
}

#add to active task list
sub addTasks
{
	my @tasktext = @_;
	if($PRINTVERBOSE == 2)
	{
		print "\nInside add subroutine: @tasktext";
	}
	
	#we have removed the actual command and now have only the remainder of argv in @_.
	#next job is to write all of it to a file...
	
	open(TODOFILE, ">>", File::Spec->catfile(($TODODIR ? $TODODIR : getcwd), "todo.txt")) or print("\n Cannot open todo.txt");
	my $datetime = localtime();
	print TODOFILE $datetime." -- @tasktext.\n";
	close (TODOFILE);
	print "\nTask @tasktext added on $datetime\n";
	listTasks();
	
}

#delete existing active tasks
sub deleteTasks
{
	my $item = shift(@_);
	
	if(defined $item && ($item =~ /^\d+$/))
	{
		if($PRINTVERBOSE == 2)
		{
			print("\nitem is a number. proceeding to delete\n");
		}
		
		open(TODOFILE, "<", File::Spec->catfile(($TODODIR ? $TODODIR : getcwd), "todo.txt")) or print("\n No Todo file exists!");
		my $count = 0;
		my @tasklist = <TODOFILE>;
		close(TODOFILE);
		
		open(TODOFILE, ">", File::Spec->catfile(($TODODIR ? $TODODIR : getcwd), "todo.txt")) or print("\n No Todo file exists!");
		$count = scalar @tasklist;
		if($PRINTVERBOSE == 2)
		{
			print "\nTasklist count: $count\n";
		}
		
		for(my $i=0; $i < $count; $i++)
		{
			if($i != ($item-1))
			{
				if($PRINTVERBOSE == 2)
				{
					print "\n $i";
				}
				print TODOFILE $tasklist[$i];
			}
		}
		close(TODOFILE);
		print ("\n Delete complete.");
		listTasks();
	}
	else
	{
		print ("\nDeleting tasks needs a task number. Please enter a number\n");
		listTasks();
	}
	
}

#mark tasks as complete and archive done tasks
sub doneTasks
{
	my $item = shift(@_);
	
	if(defined $item && ($item =~ /^\d+$/))
	{
		if($PRINTVERBOSE == 2)
		{
			print("\nitem is a number. proceeding to mark as done\n");
		}
		
		open(TODOFILE, "<", File::Spec->catfile(($TODODIR ? $TODODIR : getcwd), "todo.txt")) or print("\n No Todo file exists!");
		my $count = 0;
		my @tasklist = <TODOFILE>;
		close(TODOFILE);
		
		$count = scalar @tasklist;
		if( $item == 0 or $item > $count)
		{
			print("\nInvalid Task Number! entered. Please enter a valid number from the list.\n");
			listTasks();
			exit;
		}
		
		open(TODOFILE, ">", File::Spec->catfile(($TODODIR ? $TODODIR : getcwd), "todo.txt")) or print("\n No Todo file exists!");
		open(DONEFILE, ">>", File::Spec->catfile(($TODODIR ? $TODODIR : getcwd), "done.txt")) or print("\n Cannot create Done file!");
		
		
		if($PRINTVERBOSE == 2)
		{
			print "\nTasklist count: $count\n";
		}
		for(my $i=0; $i < $count; $i++)
		{
			if($i != ($item-1))
			{
				if($PRINTVERBOSE == 2)
				{
				print "\n $i";
				}
				print TODOFILE $tasklist[$i];
			}
			else
			{
				my $datetime = localtime();
				my @taskitem = split(/\s--\s/, $tasklist[$i]);
				print DONEFILE $datetime." -- ".$taskitem[1];
				print "\nMarking Task ".($i+1).": $taskitem[1] as done.\n";
				print "Moving to Done file.\n";
			}
		}
		close(TODOFILE);
		close(DONEFILE);
		print ("\n Delete complete.");
		listTasks();
		cleanFiles();
	}
	else
	{
		print ("\nDeleting tasks needs a valid task number from the list. Please enter a number\n");
		listTasks();
	}
}

#modify existing tasks
sub modify
{
}

#clean files for empty lines
sub cleanFiles
{
	open(TODOFILE, "+<", File::Spec->catfile(($TODODIR ? $TODODIR : getcwd), "todo.txt")) or die $!;
	my @lines;
	foreach(<TODOFILE>)
	{
		push @lines, $_ unless ($_ eq "\n");
	}
	seek(TODOFILE,0,0);
	print TODOFILE @lines;
	close(TODOFILE);
	
	open(DONEFILE, "+<", File::Spec->catfile(($TODODIR ? $TODODIR : getcwd), "done.txt")) or die $!;
	my @donelines;
	foreach(<DONEFILE>)
	{
		push @donelines, $_ unless($_ eq "\n");
	}
	seek(DONEFILE,0,0);
	print DONEFILE @donelines;
	close(DONEFILE);
}

#list tasks active in the system
sub listTasks
{
	print ("\nList of Active / Pending tasks: \n");
	open(TODOFILE, "<", File::Spec->catfile(($TODODIR ? $TODODIR : getcwd), "todo.txt")) or print("\n No Todo file exists!");
	my $count = 0;
	while(<TODOFILE>)
	{
		$count++;
		print $count.". ".$_;
	}
}

#print usage instructions. also called when @argv = 0
sub printHelp
{
	print ("Usage Instructions: \nMore to come!");
}