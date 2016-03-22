#!/usr/bin/env python

import os, sys
import datetime, time
import smtplib
from email import utils
from email.mime.text import MIMEText
from optparse import OptionParser


def main():
	parser = OptionParser(usage=""" \
Usage: %prog [Options]""")

	parser.add_option('-m', '--mailserver',
					type='string', action='store', metavar='SMTPHOST',
					help='smtp host')
	parser.add_option('-r', '--recipient',
					type='string', action='store',
					help="""recipient email address""")
	parser.add_option('-s', '--sender',
					type='string', action='store',
					help="""sender email address""")

	parser.add_option('-e', '--error',
					type='string', action='store',
					help="""error message""")

	opts, args = parser.parse_args()
	if not opts.mailserver or not opts.sender or not opts.recipient:
		parser.print_help()
		sys.exit(1)

	msg = MIMEText(opts.error)
	msg.set_charset('UTF-8')
	
	nowdt = datetime.datetime.now()
	nowtuple = nowdt.timetuple()
	nowtimestamp = time.mktime(nowtuple)
	msg.add_header('Date', utils.formatdate(nowtimestamp))

	msg['Subject'] = "Service Auto restart Email"
	msg['From'] = opts.sender
	msg['To'] = opts.recipient

	s = smtplib.SMTP(opts.mailserver)
	s.sendmail(opts.sender, opts.recipient, msg.as_string()) 
	s.quit()

if __name__ == '__main__':
	main()
