#!/usr/bin/env python
# VgmParser.py
# Python script to convert & process VGM files for SN76489 PSG
# By Simon Morris (https://github.com/simondotm/)
# Based on https://github.com/simondotm/vgm-converter
#
# Copyright (c) 2019 Simon Morris. All rights reserved.
#
# "MIT License":
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software
# is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import gzip
import struct
import sys
import binascii
import math
import random

from os.path import basename

if (sys.version_info > (3, 0)):
	from io import BytesIO as ByteBuffer
else:
	from StringIO import StringIO as ByteBuffer


class FatalError(Exception):
	pass

class VgmStream:


	# VGM commands:
	# 0x50	[dd]	= PSG SN76489 write value dd
	# 0x61	[nnnn]	= WAIT n cycles (0-65535)
	# 0x62			= WAIT 735 samples (1/60 sec)
	# 0x63			= WAIT 882 samples (1/50 sec)
	# 0x66			= END
	# 0x7n			= WAIT n+1 samples (0-15)

	#--------------------------------------------------------------------------------------------------------------------------------
	# SN76489 register writes
	# If bit 7 is 1 then the byte is a LATCH/DATA byte.
	#  %1cctdddd
	#	cc - channel (0-3)
	#	t - type (1 to latch volume, 1 to latch tone/noise)
	#	dddd - placed into the low 4 bits of the relevant register. For the three-bit noise register, the highest bit is discarded.
	#
	# If bit 7 is 0 then the byte is a DATA byte.
	#  %0-DDDDDD
	# If the currently latched register is a tone register then the low 6 bits of the byte (DDDDDD) 
	#	are placed into the high 6 bits of the latched register. If the latched register is less than 6 bits wide 
	#	(ie. not one of the tone registers), instead the low bits are placed into the corresponding bits of the 
	#	register, and any extra high bits are discarded.
	#
	# Tone registers
	#	DDDDDDdddd = cccccccccc
	#	DDDDDDdddd gives the 10-bit half-wave counter reset value.
	#
	# Volume registers
	#	(DDDDDD)dddd = (--vvvv)vvvv
	#	dddd gives the 4-bit volume value.
	#	If a data byte is written, the low 4 bits of DDDDDD update the 4-bit volume value. However, this is unnecessary.
	#
	# Noise register
	#	(DDDDDD)dddd = (---trr)-trr
	#	The low 2 bits of dddd select the shift rate and the next highest bit (bit 2) selects the mode (white (1) or "periodic" (0)).
	#	If a data byte is written, its low 3 bits update the shift rate and mode in the same way.
	#--------------------------------------------------------------------------------------------------------------------------------

	# script vars / configs

	VGM_FREQUENCY = 44100


	# script options
	RETUNE_PERIODIC = True	# [TO BE REMOVED] if true will attempt to retune any use of the periodic noise effect
	VERBOSE = False
	STRIP_GD3 = False	
	LENGTH = 0 # required output length (in seconds)
	
	# VGM file identifier
	vgm_magic_number = b'Vgm '

	disable_dual_chip = True # [TODO] handle dual PSG a bit better

	vgm_source_clock = 0
	vgm_target_clock = 0
	vgm_filename = ''
	vgm_loop_offset = 0
	vgm_loop_length = 0
	
	# Supported VGM versions
	supported_ver_list = [
		0x00000101,
		0x00000110,
		0x00000150,
		0x00000151,
		0x00000160,
		0x00000161,
	]

	# VGM metadata offsets
	metadata_offsets = {
		# SDM Hacked version number 101 too
		0x00000101: {
			'vgm_ident': {'offset': 0x00, 'size': 4, 'type_format': None},
			'eof_offset': {'offset': 0x04, 'size': 4, 'type_format': '<I'},
			'version': {'offset': 0x08, 'size': 4, 'type_format': '<I'},
			'sn76489_clock': {'offset': 0x0c, 'size': 4, 'type_format': '<I'},
			'ym2413_clock': {'offset': 0x10, 'size': 4, 'type_format': '<I'},
			'gd3_offset': {'offset': 0x14, 'size': 4, 'type_format': '<I'},
			'total_samples': {'offset': 0x18, 'size': 4, 'type_format': '<I'},
			'loop_offset': {'offset': 0x1c, 'size': 4, 'type_format': '<I'},
			'loop_samples': {'offset': 0x20, 'size': 4, 'type_format': '<I'},
			'rate': {'offset': 0x24, 'size': 4, 'type_format': '<I'},
			'sn76489_feedback': {
				'offset': 0x28,
				'size': 2,
				'type_format': '<H',
			},
			'sn76489_shift_register_width': {
				'offset': 0x2a,
				'size': 1,
				'type_format': 'B',
			},
			'ym2612_clock': {'offset': 0x2c, 'size': 4, 'type_format': '<I'},
			'ym2151_clock': {'offset': 0x30, 'size': 4, 'type_format': '<I'},
			'vgm_data_offset': {
				'offset': 0x34,
				'size': 4,
				'type_format': '<I',
			},
		},

		# Version 1.10`
		0x00000110: {
			'vgm_ident': {'offset': 0x00, 'size': 4, 'type_format': None},
			'eof_offset': {'offset': 0x04, 'size': 4, 'type_format': '<I'},
			'version': {'offset': 0x08, 'size': 4, 'type_format': '<I'},
			'sn76489_clock': {'offset': 0x0c, 'size': 4, 'type_format': '<I'},
			'ym2413_clock': {'offset': 0x10, 'size': 4, 'type_format': '<I'},
			'gd3_offset': {'offset': 0x14, 'size': 4, 'type_format': '<I'},
			'total_samples': {'offset': 0x18, 'size': 4, 'type_format': '<I'},
			'loop_offset': {'offset': 0x1c, 'size': 4, 'type_format': '<I'},
			'loop_samples': {'offset': 0x20, 'size': 4, 'type_format': '<I'},
			'rate': {'offset': 0x24, 'size': 4, 'type_format': '<I'},
			'sn76489_feedback': {
				'offset': 0x28,
				'size': 2,
				'type_format': '<H',
			},
			'sn76489_shift_register_width': {
				'offset': 0x2a,
				'size': 1,
				'type_format': 'B',
			},
			'ym2612_clock': {'offset': 0x2c, 'size': 4, 'type_format': '<I'},
			'ym2151_clock': {'offset': 0x30, 'size': 4, 'type_format': '<I'},
			'vgm_data_offset': {
				'offset': 0x34,
				'size': 4,
				'type_format': '<I',
			},
		},
		# Version 1.50`
		0x00000150: {
			'vgm_ident': {'offset': 0x00, 'size': 4, 'type_format': None},
			'eof_offset': {'offset': 0x04, 'size': 4, 'type_format': '<I'},
			'version': {'offset': 0x08, 'size': 4, 'type_format': '<I'},
			'sn76489_clock': {'offset': 0x0c, 'size': 4, 'type_format': '<I'},
			'ym2413_clock': {'offset': 0x10, 'size': 4, 'type_format': '<I'},
			'gd3_offset': {'offset': 0x14, 'size': 4, 'type_format': '<I'},
			'total_samples': {'offset': 0x18, 'size': 4, 'type_format': '<I'},
			'loop_offset': {'offset': 0x1c, 'size': 4, 'type_format': '<I'},
			'loop_samples': {'offset': 0x20, 'size': 4, 'type_format': '<I'},
			'rate': {'offset': 0x24, 'size': 4, 'type_format': '<I'},
			'sn76489_feedback': {
				'offset': 0x28,
				'size': 2,
				'type_format': '<H',
			},
			'sn76489_shift_register_width': {
				'offset': 0x2a,
				'size': 1,
				'type_format': 'B',
			},
			'ym2612_clock': {'offset': 0x2c, 'size': 4, 'type_format': '<I'},
			'ym2151_clock': {'offset': 0x30, 'size': 4, 'type_format': '<I'},
			'vgm_data_offset': {
				'offset': 0x34,
				'size': 4,
				'type_format': '<I',
			},
		},
		# SDM Hacked version number, we are happy enough to parse v1.51 as if it were 1.50 since the 1.51 updates dont apply to us anyway
		0x00000151: {
			'vgm_ident': {'offset': 0x00, 'size': 4, 'type_format': None},
			'eof_offset': {'offset': 0x04, 'size': 4, 'type_format': '<I'},
			'version': {'offset': 0x08, 'size': 4, 'type_format': '<I'},
			'sn76489_clock': {'offset': 0x0c, 'size': 4, 'type_format': '<I'},
			'ym2413_clock': {'offset': 0x10, 'size': 4, 'type_format': '<I'},
			'gd3_offset': {'offset': 0x14, 'size': 4, 'type_format': '<I'},
			'total_samples': {'offset': 0x18, 'size': 4, 'type_format': '<I'},
			'loop_offset': {'offset': 0x1c, 'size': 4, 'type_format': '<I'},
			'loop_samples': {'offset': 0x20, 'size': 4, 'type_format': '<I'},
			'rate': {'offset': 0x24, 'size': 4, 'type_format': '<I'},
			'sn76489_feedback': {
				'offset': 0x28,
				'size': 2,
				'type_format': '<H',
			},
			'sn76489_shift_register_width': {
				'offset': 0x2a,
				'size': 1,
				'type_format': 'B',
			},
			'ym2612_clock': {'offset': 0x2c, 'size': 4, 'type_format': '<I'},
			'ym2151_clock': {'offset': 0x30, 'size': 4, 'type_format': '<I'},
			'vgm_data_offset': {
				'offset': 0x34,
				'size': 4,
				'type_format': '<I',
			},
		},
		# SDM Hacked version number, we are happy enough to parse v1.60 as if it were 1.50 since the 1.51 updates dont apply to us anyway
		0x00000160: {
			'vgm_ident': {'offset': 0x00, 'size': 4, 'type_format': None},
			'eof_offset': {'offset': 0x04, 'size': 4, 'type_format': '<I'},
			'version': {'offset': 0x08, 'size': 4, 'type_format': '<I'},
			'sn76489_clock': {'offset': 0x0c, 'size': 4, 'type_format': '<I'},
			'ym2413_clock': {'offset': 0x10, 'size': 4, 'type_format': '<I'},
			'gd3_offset': {'offset': 0x14, 'size': 4, 'type_format': '<I'},
			'total_samples': {'offset': 0x18, 'size': 4, 'type_format': '<I'},
			'loop_offset': {'offset': 0x1c, 'size': 4, 'type_format': '<I'},
			'loop_samples': {'offset': 0x20, 'size': 4, 'type_format': '<I'},
			'rate': {'offset': 0x24, 'size': 4, 'type_format': '<I'},
			'sn76489_feedback': {
				'offset': 0x28,
				'size': 2,
				'type_format': '<H',
			},
			'sn76489_shift_register_width': {
				'offset': 0x2a,
				'size': 1,
				'type_format': 'B',
			},
			'ym2612_clock': {'offset': 0x2c, 'size': 4, 'type_format': '<I'},
			'ym2151_clock': {'offset': 0x30, 'size': 4, 'type_format': '<I'},
			'vgm_data_offset': {
				'offset': 0x34,
				'size': 4,
				'type_format': '<I',
			},
			
		},		
		# SDM Hacked version number, we are happy enough to parse v1.61 as if it were 1.50 since the 1.51 updates dont apply to us anyway
		0x00000161: {
			'vgm_ident': {'offset': 0x00, 'size': 4, 'type_format': None},
			'eof_offset': {'offset': 0x04, 'size': 4, 'type_format': '<I'},
			'version': {'offset': 0x08, 'size': 4, 'type_format': '<I'},
			'sn76489_clock': {'offset': 0x0c, 'size': 4, 'type_format': '<I'},
			'ym2413_clock': {'offset': 0x10, 'size': 4, 'type_format': '<I'},
			'gd3_offset': {'offset': 0x14, 'size': 4, 'type_format': '<I'},
			'total_samples': {'offset': 0x18, 'size': 4, 'type_format': '<I'},
			'loop_offset': {'offset': 0x1c, 'size': 4, 'type_format': '<I'},
			'loop_samples': {'offset': 0x20, 'size': 4, 'type_format': '<I'},
			'rate': {'offset': 0x24, 'size': 4, 'type_format': '<I'},
			'sn76489_feedback': {
				'offset': 0x28,
				'size': 2,
				'type_format': '<H',
			},
			'sn76489_shift_register_width': {
				'offset': 0x2a,
				'size': 1,
				'type_format': 'B',
			},
			'ym2612_clock': {'offset': 0x2c, 'size': 4, 'type_format': '<I'},
			'ym2151_clock': {'offset': 0x30, 'size': 4, 'type_format': '<I'},
			'vgm_data_offset': {
				'offset': 0x34,
				'size': 4,
				'type_format': '<I',
			},
		}
	}

	
	# constructor - pass in the filename of the VGM
	def __init__(self, vgm_filename):

		self.vgm_filename = vgm_filename
		print("  VGM file loaded : '" + vgm_filename + "'")
		
		# open the vgm file and parse it
		vgm_file = open(vgm_filename, 'rb')
		vgm_data = vgm_file.read()
		
		# Store the VGM data and validate it
		self.data = ByteBuffer(vgm_data)
		
		vgm_file.close()
		
		# parse
		self.validate_vgm_data()

		# Set up the variables that will be populated
		self.command_list = []
		self.data_block = None
		self.gd3_data = {}
		self.metadata = {}

		# Parse the VGM metadata and validate the VGM version
		self.parse_metadata()
		
		# Display info about the file
		self.vgm_loop_offset = self.metadata['loop_offset']
		self.vgm_loop_length = self.metadata['loop_samples']
		
		print("      VGM Version : " + "%x" % int(self.metadata['version']) )
		print("VGM SN76489 clock : " + str(float(self.metadata['sn76489_clock'])/1000000) + " MHz" )
		print("         VGM Rate : " + str(float(self.metadata['rate'])) + " Hz" )
		print("      VGM Samples : " + str(int(self.metadata['total_samples'])) + " (" + str(int(self.metadata['total_samples'])/self.VGM_FREQUENCY) + " seconds)" )
		print("  VGM Loop Offset : " + str(self.vgm_loop_offset) )
		print("  VGM Loop Length : " + str(self.vgm_loop_length) )




		# Validation to check we can parse it
		self.validate_vgm_version()

		# Sanity check this VGM is suitable for this script - must be SN76489 only
		if self.metadata['sn76489_clock'] == 0 or self.metadata['ym2413_clock'] !=0 or self.metadata['ym2413_clock'] !=0 or self.metadata['ym2413_clock'] !=0:
			raise FatalError("This script only supports VGM's for SN76489 PSG")		
		
		# see if this VGM uses Dual Chip mode
		if (self.metadata['sn76489_clock'] & 0x40000000) == 0x40000000:
			self.dual_chip_mode_enabled = True
		else:
			self.dual_chip_mode_enabled = False
			
		print("    VGM Dual Chip : " + str(self.dual_chip_mode_enabled) )
		

		# override/disable dual chip commands in the output stream if required
		if (self.disable_dual_chip == True) and (self.dual_chip_mode_enabled == True) :
			# remove the clock flag that enables dual chip mode
			self.metadata['sn76489_clock'] = self.metadata['sn76489_clock'] & 0xbfffffff
			self.dual_chip_mode_enabled = False
			print( "Dual Chip Mode Disabled - DC Commands will be removed" )

		# take a copy of the clock speed for the VGM processor functions
		self.vgm_source_clock = self.metadata['sn76489_clock']
		self.vgm_target_clock = self.vgm_source_clock
		
		# Parse GD3 data and the VGM commands
		self.parse_gd3()
		self.parse_commands()
		
		print( "   VGM Commands # : " + str(len(self.command_list)) )
		print( "" )


	def validate_vgm_data(self):
		# Save the current position of the VGM data
		original_pos = self.data.tell()

		# Seek to the start of the file
		self.data.seek(0)

		# Perform basic validation on the given file by checking for the VGM
		# magic number ('Vgm ')
		if self.data.read(4) != self.vgm_magic_number:
			# Could not find the magic number. The file could be gzipped (e.g.
			# a vgz file). Try un-gzipping the file and trying again.
			self.data.seek(0)
			self.data = gzip.GzipFile(fileobj=self.data, mode='rb')

			try:
				if self.data.read(4) != self.vgm_magic_number:
					print( "Error: Data does not appear to be a valid VGM file" )
					raise ValueError('Data does not appear to be a valid VGM file')
			except IOError:
				print( "Error: Data does not appear to be a valid VGM file" )
				# IOError will be raised if the file is not a valid gzip file
				raise ValueError('Data does not appear to be a valid VGM file')

		# Seek back to the original position in the VGM data
		self.data.seek(original_pos)
		
	def parse_metadata(self):
		# Save the current position of the VGM data
		original_pos = self.data.tell()

		# Create the list to store the VGM metadata
		self.metadata = {}

		# Iterate over the offsets and parse the metadata
		for version, offsets in self.metadata_offsets.items():
			for value, offset_data in offsets.items():

				# Seek to the data location and read the data
				self.data.seek(offset_data['offset'])
				data = self.data.read(offset_data['size'])

				# Unpack the data if required
				if offset_data['type_format'] is not None:
					self.metadata[value] = struct.unpack(
						offset_data['type_format'],
						data,
					)[0]
				else:
					self.metadata[value] = data

		# Seek back to the original position in the VGM data
		self.data.seek(original_pos)

	def validate_vgm_version(self):
		if self.metadata['version'] not in self.supported_ver_list:
			print( "VGM version is not supported" )
			raise FatalError('VGM version is not supported')

	def parse_gd3(self):
		# Save the current position of the VGM data
		original_pos = self.data.tell()

		# Seek to the start of the GD3 data
		self.data.seek(
			self.metadata['gd3_offset'] +
			self.metadata_offsets[self.metadata['version']]['gd3_offset']['offset']
		)

		# Skip 8 bytes ('Gd3 ' string and 4 byte version identifier)
		self.data.seek(8, 1)

		# Get the length of the GD3 data, then read it
		gd3_length = struct.unpack('<I', self.data.read(4))[0]
		gd3_data = ByteBuffer(self.data.read(gd3_length))

		# Parse the GD3 data
		gd3_fields = []
		current_field = b''
		while True:
			# Read two bytes. All characters (English and Japanese) in the GD3
			# data use two byte encoding
			char = gd3_data.read(2)

			# Break if we are at the end of the GD3 data
			if char == b'':
				break

			# Check if we are at the end of a field, if not then continue to
			# append to "current_field"
			if char == b'\x00\x00':
				gd3_fields.append(current_field)
				current_field = b''
			else:
				current_field += char

		# Once all the fields have been parsed, create a dict with the data
		# some Gd3 tags dont have notes section
		gd3_notes = ''
		gd3_title_eng = basename(self.vgm_filename).encode("utf_16")
		if len(gd3_fields) > 10:
			gd3_notes = gd3_fields[10]
			
		if len(gd3_fields) > 8:
		
			if len(gd3_fields[0]) > 0:
				gd3_title_eng = gd3_fields[0]

				
			self.gd3_data = {
				'title_eng': gd3_title_eng,
				'title_jap': gd3_fields[1],
				'game_eng': gd3_fields[2],
				'game_jap': gd3_fields[3],
				'console_eng': gd3_fields[4],
				'console_jap': gd3_fields[5],
				'artist_eng': gd3_fields[6],
				'artist_jap': gd3_fields[7],
				'date': gd3_fields[8],
				'vgm_creator': gd3_fields[9],
				'notes': gd3_notes
			}		
		else:
			print( "WARNING: Malformed/missing GD3 tag" )
			self.gd3_data = {
				'title_eng': gd3_title_eng,
				'title_jap': '',
				'game_eng': '',
				'game_jap': '',
				'console_eng': '',
				'console_jap': '',
				'artist_eng': 'Unknown'.encode("utf_16"),
				'artist_jap': '',
				'date': '',
				'vgm_creator': '',
				'notes': ''
			}				


		# Seek back to the original position in the VGM data
		self.data.seek(original_pos)

	#-------------------------------------------------------------------------------------------------

	def parse_commands(self):
		# Save the current position of the VGM data
		original_pos = self.data.tell()

		# Seek to the start of the VGM data
		self.data.seek(
			self.metadata['vgm_data_offset'] +
			self.metadata_offsets[self.metadata['version']]['vgm_data_offset']['offset']
		)

		while True:
			# Read a byte, this will be a VGM command, we will then make
			# decisions based on the given command
			command = self.data.read(1)

			# Break if we are at the end of the file
			if command == '':
				break

			# 0x4f dd - Game Gear PSG stereo, write dd to port 0x06
			# 0x50 dd - PSG (SN76489/SN76496) write value dd
			if command in [b'\x4f', b'\x50']:
				self.command_list.append({
					'command': command,
					'data': self.data.read(1),
				})

			# 0x51 aa dd - YM2413, write value dd to register aa
			# 0x52 aa dd - YM2612 port 0, write value dd to register aa
			# 0x53 aa dd - YM2612 port 1, write value dd to register aa
			# 0x54 aa dd - YM2151, write value dd to register aa
			elif command in [b'\x51', b'\x52', b'\x53', b'\x54']:
				self.command_list.append({
					'command': command,
					'data': self.data.read(2),
				})

			# 0x61 nn nn - Wait n samples, n can range from 0 to 65535
			elif command == b'\x61':
				self.command_list.append({
					'command': command,
					'data': self.data.read(2),
				})

			# 0x62 - Wait 735 samples (60th of a second)
			# 0x63 - Wait 882 samples (50th of a second)
			# 0x66 - End of sound data
			elif command in [b'\x62', b'\x63', b'\x66']:
				self.command_list.append({'command': command, 'data': None})

				# Stop processing commands if we are at the end of the music
				# data
				if command == b'\x66':
					break

			# 0x67 0x66 tt ss ss ss ss - Data block
			elif command == b'\x67':
				# Skip the compatibility and type bytes (0x66 tt)
				self.data.seek(2, 1)

				# Read the size of the data block
				data_block_size = struct.unpack('<I', self.data.read(4))[0]

				# Store the data block for later use
				self.data_block = ByteBuffer(self.data.read(data_block_size))

			# 0x7n - Wait n+1 samples, n can range from 0 to 15
			# 0x8n - YM2612 port 0 address 2A write from the data bank, then
			#        wait n samples; n can range from 0 to 15
			elif b'\x70' <= command <= b'\x8f':
				self.command_list.append({'command': command, 'data': None})

			# 0xe0 dddddddd - Seek to offset dddddddd (Intel byte order) in PCM
			#                 data bank
			elif command == b'\xe0':
				self.command_list.append({
					'command': command,
					'data': self.data.read(4),
				})
				
			# 0x30 dd - dual chip command
			elif command == b'\x30':
				if self.dual_chip_mode_enabled:
					self.command_list.append({
						'command': command,
						'data': self.data.read(1),
					})
			

		# Seek back to the original position in the VGM data
		self.data.seek(original_pos)


	#-------------------------------------------------------------------------------------------------
	
	# returns bytearray containing the raw data version of the vgm
	def as_binary(self, rawheader = True):
		print( "   VGM Processing : Output binary file " )

		byte_size = 1
		packet_size = 0
		play_rate = self.metadata['rate']
		play_interval = self.VGM_FREQUENCY / play_rate
		data_block = bytearray()
		packet_block = bytearray()

		packet_count = 0

		# emit the packet data
		for q in self.command_list:
			
			command = q["command"]
			if command != struct.pack('B', 0x50):
			
				# non-write command, so flush any pending packet data
				if self.VERBOSE: print( "Packet length " + str(len(packet_block)) )

				# python 3 struct.pack returns iterable "bytes" even if len is 1, so we use extend rather than append since this is compatible with python 2 and 3
				#data_block.append( struct.pack('B', len(packet_block) ) )
				data_block.extend( struct.pack('B', len(packet_block) ) )
				
				data_block.extend(packet_block)
				packet_count += 1
				
				#if packet_count > 30*play_rate:
				#	break

				# start new packet
				packet_block = bytearray()
				
				if self.VERBOSE: print( "Command " + str(binascii.hexlify(command)) )
				
				

				# see if command is a wait longer than one interval and emit empty packets to compensate
				wait = 0
				if command == struct.pack('B', 0x61):
					t = int(binascii.hexlify(q["data"]), 16)
					wait = ((t & 255) * 256) + (t>>8)
				else:
					if command == struct.pack('B', 0x62):
						wait = 735
					else:
						if command == struct.pack('B', 0x63):
							wait = 	882
					
				if wait != 0:	
					intervals = wait / (self.VGM_FREQUENCY / play_rate)
					if intervals == 0:
						print( "ERROR in data stream, wait value (" + str(wait) + ") was not divisible by play_rate (" + str((self.VGM_FREQUENCY / play_rate)) + "), bailing" )
						return
					else:
						if self.VERBOSE: print( "WAIT " + str(intervals) + " intervals" )
						
					# emit empty packet headers to simulate wait commands
					intervals -= 1
					while intervals > 0:
						data_block.append(0)
						if self.VERBOSE: print( "Packet length 0" )
						intervals -= 1
						packet_count += 1

				
				
			else:
				if self.VERBOSE: print( "Data " + str(binascii.hexlify(command)) )
				packet_block.extend(q['data'])

		# eof
		data_block.append(0x00)	# append one last wait
		data_block.append(0xFF)	# signal EOF


		header_block = bytearray()
		# emit the play rate
		print( "play rate is " + str(play_rate) )
		# python 3 struct.pack returns iterable "bytes" even if len is 1, so we use extend rather than append since this is compatible with python 2 and 3
		header_block.extend(struct.pack('B', play_rate & 0xff))
		header_block.extend(struct.pack('B', packet_count & 0xff))		
		header_block.extend(struct.pack('B', (packet_count >> 8) & 0xff))	

		print( "    Num packets " + str(packet_count) )
		duration = packet_count / play_rate
		duration_mm = int(duration / 60.0)
		duration_ss = int(duration % 60.0)
		print( "    Song duration " + str(duration) + " seconds, " + str(duration_mm) + "m" + str(duration_ss) + "s" )
		header_block.extend(struct.pack('B', duration_mm))	# minutes		
		header_block.extend(struct.pack('B', duration_ss))	# seconds

		# output the final byte stream
		output_block = bytearray()	

		# send header
		output_block.extend(struct.pack('B', len(header_block)))
		output_block.extend(header_block)

		# send title
		title = self.gd3_data['title_eng'].decode("utf_16")
		title = title.encode('ascii', 'ignore')

		if len(title) > 254:
			title = title[:254]
		output_block.extend(struct.pack('B', len(title) + 1))	# title string length
		output_block.extend(title)
		output_block.extend(struct.pack('B', 0))				# zero terminator

		# send author
		author = self.gd3_data['artist_eng'].decode("utf_16")
		author = author.encode('ascii', 'ignore')

		# use filename if no author listed
		if len(author) == 0:
			author = basename(self.vgm_filename)

		if len(author) > 254:
			author = author[:254]
		output_block.extend(struct.pack('B', len(author) + 1))	# author string length
		output_block.extend(author)
		output_block.extend(struct.pack('B', 0))				# zero terminator

		# send data with or without header
		if rawheader:
			output_block.extend(data_block)
		else:
			output_block = data_block

		# write file
		print( "Compressed VGM is " + str(len(output_block)) + " bytes long" )

		return output_block



			
	# write vgm file (with same header data as the input, but from binary register data)
	# registers is an array of 11 byte arrays, each byte array containing the tune data
	def write_vgm(self, vgm_stream, filename):
			
		print("   Writing output VGM file '" + filename + "'")


		vgm_stream_length = len(vgm_stream)		

		# build the GD3 data block
		gd3_data = bytearray()
		gd3_stream = bytearray()	
		gd3_stream_length = 0
		
		gd3_offset = 0
		if self.STRIP_GD3 == False:
			gd3_data.extend(self.gd3_data['title_eng'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['title_jap'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['game_eng'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['game_jap'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['console_eng'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['console_jap'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['artist_eng'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['artist_jap'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['date'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['vgm_creator'] + b'\x00\x00')
			gd3_data.extend(self.gd3_data['notes'] + b'\x00\x00')
			
			gd3_stream.extend(b'Gd3 ')
			gd3_stream.extend(struct.pack('I', 0x100))				# GD3 version
			gd3_stream.extend(struct.pack('I', len(gd3_data)))		# GD3 length		
			gd3_stream.extend(gd3_data)		
			
			gd3_offset = (64-20) + vgm_stream_length
			gd3_stream_length = len(gd3_stream)
		else:
			print("   VGM Processing : GD3 tag was stripped")
		
		# build the full VGM output stream		
		vgm_data = bytearray()
		vgm_data.extend(self.vgm_magic_number)
		vgm_data.extend(struct.pack('I', 64 + vgm_stream_length + gd3_stream_length - 4))				# EoF offset
		vgm_data.extend(struct.pack('I', 0x00000151))		# Version
		vgm_data.extend(struct.pack('I', self.metadata['sn76489_clock']))
		vgm_data.extend(struct.pack('I', self.metadata['ym2413_clock']))
		vgm_data.extend(struct.pack('I', gd3_offset))				# GD3 offset
		vgm_data.extend(struct.pack('I', self.metadata['total_samples']))				# total samples
		vgm_data.extend(struct.pack('I', 0)) #self.metadata['loop_offset']))				# loop offset
		vgm_data.extend(struct.pack('I', 0)) #self.metadata['loop_samples']))				# loop # samples
		vgm_data.extend(struct.pack('I', self.metadata['rate']))				# rate
		vgm_data.extend(struct.pack('H', self.metadata['sn76489_feedback']))				# sn fb
		vgm_data.extend(struct.pack('B', self.metadata['sn76489_shift_register_width']))				# SNW	
		vgm_data.extend(struct.pack('B', 0))				# SN Flags			
		vgm_data.extend(struct.pack('I', self.metadata['ym2612_clock']))		
		vgm_data.extend(struct.pack('I', self.metadata['ym2151_clock']))	
		vgm_data.extend(struct.pack('I', 12))				# VGM data offset
		vgm_data.extend(struct.pack('I', 0))				# SEGA PCM clock	
		vgm_data.extend(struct.pack('I', 0))				# SPCM interface	

		# attach the vgm data
		vgm_data.extend(vgm_stream)

		# attach the vgm gd3 tag if required
		if self.STRIP_GD3 == False:
			vgm_data.extend(gd3_stream)
		
		# write to output file
		vgm_file = open(filename, 'wb')
		vgm_file.write(vgm_data)
		vgm_file.close()
		
		print("   VGM Processing : Written " + str(int(len(vgm_data))) + " bytes, GD3 tag used " + str(gd3_stream_length) + " bytes")
		
		print("All done.")	