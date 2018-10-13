=begin --------------------------------------------------------------------------------------------
// Name: Daniel Hanna
// Course: CSC 415
// Semester: Fall 2018
// Instructor: Dr. Pulimood 
// Project name: tcnjParkingSpaces (Assignment 1)
// Description: Ruby program to suggest what TCNJ lots have open spaces based on user input 
// Filename: tcnjParkingSpaces.rb 
// Description: contains methods for introduction, checking the csv file location, mapping csv
//              files to a hash tables, considering the user's member titles, determining 'legal'
//              parking lots based on user constraints, and predicting the best lot out of those
//              'legal' lots
// Last modified on: 10/13/2018
--------------------------------------------------------------------------------------------------

<tcnjParkingSpaces - algorithm to suggest best parking lots on TCNJ's campus.>
    Copyright (C) 2018  Daniel Hanna

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------------------------
=end

require 'pathname'        # require pathname to check if user's path exists
require 'csv'             # require csv to be able to read csv files
require 'time'            # require time to manipulate user's time inputs


#-------------------------------CONSTANTS------------------------------------
# Any changes to CSV Headings or times can be easily serviced in the program
# through these constants

CONSTRAINTS_LOT_HEADING = "Parking Lot"
CONSTRAINTS_LOTS_CLOSED = "Dates Lot Will be Closed"

CONSTRAINTS_PERMISSIONS_HEADING1 = "Permissions Mon through Thurs 2:30am to 5:00 am"
HEADING1_TIME1 = "02:30 AM"
HEADING1_TIME2 = "4:59 AM"

CONSTRAINTS_PERMISSIONS_HEADING2 = "Permissions Mon through Fri 5:00am to 4:00pm"
HEADING2_TIME1 = "5:00 AM"
HEADING2_TIME2 = "3:59 PM"

CONSTRAINTS_PERMISSIONS_HEADING3 = "Permissions Mon through Thurs 4pm to 2:30am"
HEADING3_TIME1 = "4:00 PM"
HEADING3_TIME2 = "2:29 AM"

CONSTRAINTS_PERMISSIONS_HEADING4 = "Permissions Fri through Sun 4:00pm to 9:00pm"
HEADING4_TIME1 = "4:00 PM"
HEADING4_TIME2 = "8:59 PM"

#----------------------------------------------------------------------------


=begin -------------------------------------------------------------------------------------------
//  Method: predictBestLot()
//    Parameters: lotsConstraintsHash, historicParkingHash, possibleLots, userDate, timeofDay
//    Pre-condition:  possibleLots is appended with 'legal' lots for user to park in. possibleLots
//                    may be empty if no lots are found using user's constraints. User entered
//                    appropriate information according to formatting guidelines displayed on screen.
//    Post-condition: The best parking lot will be outputted to screen. If no lots are 'legal'
//                    for user to park in, no information will be printed on screen. Program will
//                    terminate.
//------------------------------------------------------------------------------------------------
=end

def predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)  # Method to predict best lot for parking
  items = possibleLots.count          # create variable items that has value of the number of lots (elements) present in possibleLots array
  if userDate.is_a? String            # checking if userDate parameter is of type String
    userDate = Date.strptime(userDate, '%m/%d/%Y')    # if userDate is of type string, date information will be extracted from it and reassigned to itself
  end
  userDate = userDate.prev_year       # convert users date to previous year in order to compare it to historicParkingHash dates
  historicalLotData = []              # create empty array historicalLotData
  for variable in 0..items-1          # iterate through length of possibleLots
    matchingData =  historicParkingHash.find { |i|  # for the historicParkingHash, find where parking lot matches to element in possibleLots & date matches the user's date (moved back 1 year) & time's hour matches user's time's hour
      i[CONSTRAINTS_LOT_HEADING] == possibleLots[variable] and Date.strptime(i["Date"], '%m/%d/%Y') == userDate and Time.parse(i["Time"]).hour == timeOfDay.hour }
    if matchingData == nil        # matchingData will be nil if userDate is not found in historical lots file, in which case year will be moved back by 1 year again (method will be restarted)
      predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)    # method will rerun until userDate is found in historical data
      return 0          # return 0 to avoid complications when rerunning method
    end
    historicalLotData << matchingData    # if matchingData is not nil, append it to historicalLotData array
  end

  finalArray = []             # create finalArray to store number of open spots
  for counter in 0..historicalLotData.count-1     # loop through length of historicalLotData
    finalArray << historicalLotData[counter]["Capacity"]-historicalLotData[counter]["Spots Taken"]   # number of open spots = Capacity - spots taken. Append that to finalArray
  end
  puts "\n\nIt is predicted that the best lot for you to find parking is: "

  if historicalLotData.empty?       # historicalLotData will be empty if matchingData is empty after the historicParkingHash is searched
    puts "No lots are predicted because no permissions are found for your member title at the time you entered.\n\n"
    puts "Would you like to restart the program? Please enter 'yes' or 'no'\n"
    userRestart = gets.chomp
    userRestart.upcase!           # Converting user input (to avoid case sensitive issue)
    if userRestart == "YES" or userRestart == "Y"
      system "clear" or system "cls"
      puts "OK! The program will restart now!\n\n\n"
      csvLocation         # Restart program depending on user input (restart as csv input, since user already knows the introduction)
      return 0
    else
      puts "\nThank you for using this program. Goodbye!"
      return 0
    end
    return 0
  end
  puts historicalLotData[finalArray.index(finalArray.max)][CONSTRAINTS_LOT_HEADING]     # Print the lot with the highest number of open spots
  print "Estimated number of spots available: "
  puts finalArray.max                                       # Print number of spots available
  puts "Would you like to restart the program? Please enter 'yes' or 'no'\n"
  userRestart = gets.chomp
  userRestart.upcase!         # Converting user input (to avoid case sensitive issue)
  if userRestart == "YES" or userRestart == "Y"
    system "clear" or system "cls"
    puts "OK! The program will restart now!\n\n\n"
    csvLocation           # Restart program depending on user input (restart as csv input, since user already knows the introduction)
    return 0
  else
    puts "\nThank you for using this program. Goodbye!"
    return 0                                                # Return 0 to terminate program
  end
end


=begin -------------------------------------------------------------------------------------------
//  Method: weekDayCalculation()
//    Parameters:     lotConstraintsHash, historicParkingHash, userPermission, userDate, timeOfDay,
//                    dayOfWeek
//    Pre-condition:  The user entered a Monday-Thursday dayOfWeek input and a timeOfDay input
//    Post-condition: Based on user input, a new function will be invoked that will calculate
//                    legal lots for the user to park in based on lot time constraints.
//------------------------------------------------------------------------------------------------
=end

def weekDayCalculation(lotConstraintsHash, historicParkingHash, userPermission, userDate, timeOfDay, dayOfWeek)
  possibleLots = Array.new
  puts "Based on your permissions and parking time info, you can park in the following lots:\n"
  if timeOfDay >= Time.parse(HEADING1_TIME1) && timeOfDay <= Time.parse(HEADING1_TIME2)    # Check if users time is between 2:30-5:00AM for Monday - Thursday
    i1 = 0                        # simple dummy/counter variable (used for indexing)
    while i1 < lotConstraintsHash.count()     # create loop that will run for length of lotConstraintsHash (will run for all parking lots in lotConstraintsHash)
      if (lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING1].nil?)   # if no user permissions exists for a particular lot, that lot will be skipped
        i1 = i1 +  1              # increment dummy/counter variable to skip lots with empty permissions

        # if user permissions for a particular lot is not empty, then permissions will be checked to see if they match with users member title or matches with "All"
      elsif (lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING1].upcase.include? userPermission or lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING1].include? "All")
        if (lotConstraintsHash[i1][CONSTRAINTS_LOTS_CLOSED].include? userDate)   # if lot will be closed on same date as users date, don't include that lot in the results
          i1 = i1 + 1     # increment dummy counter so that closed lot won't be included in result
        else
          possibleLots.push(lotConstraintsHash[i1][CONSTRAINTS_LOT_HEADING])    # Add the lots that user can park in into the possibleLots array
          print lotConstraintsHash[i1][CONSTRAINTS_LOT_HEADING] + " | "         # Print out the lots that user can park in
          i1 = i1 + 1
        end
      else
        i1 = i1 + 1
      end
    end
    predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)  # go to predictBestLot method to predict the best lot for parking
    return 0

  elsif timeOfDay >= Time.parse(HEADING2_TIME1) && timeOfDay <= Time.parse(HEADING2_TIME2)    # similar check to above, see comments
    i2 = 0
    while i2 < lotConstraintsHash.count()
      if (lotConstraintsHash[i2][CONSTRAINTS_PERMISSIONS_HEADING2].nil?)
        i2 = i2 +  1
      elsif (lotConstraintsHash[i2][CONSTRAINTS_PERMISSIONS_HEADING2].upcase.include? userPermission or lotConstraintsHash[i2][CONSTRAINTS_PERMISSIONS_HEADING2].include? "All")
        if (lotConstraintsHash[i2][CONSTRAINTS_LOTS_CLOSED].include? userDate)
          i2 = i2 + 1
        else
          possibleLots.push(lotConstraintsHash[i2][CONSTRAINTS_LOT_HEADING])
          print lotConstraintsHash[i2][CONSTRAINTS_LOT_HEADING] + " | "
          i2 = i2 + 1
        end
      else
        i2 = i2 + 1
      end
    end
    predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)  # go to predictBestLot method to predict the best lot for parking
    return 0

  else timeOfDay >= Time.parse(HEADING3_TIME1) && timeOfDay <= Time.parse(HEADING3_TIME2)     # Only other time to check will be the left over time for Monday - Thursday. See comments above for method
    i3 = 0
    while i3 < lotConstraintsHash.count()
      if (lotConstraintsHash[i3][CONSTRAINTS_PERMISSIONS_HEADING3].nil?)
        i3 = i3 +  1
      elsif (lotConstraintsHash[i3][CONSTRAINTS_PERMISSIONS_HEADING3].upcase.include? userPermission or lotConstraintsHash[i3][CONSTRAINTS_PERMISSIONS_HEADING3].include? "All")
        if (lotConstraintsHash[i3][CONSTRAINTS_LOTS_CLOSED].include? userDate)
          i3 = i3 + 1
        else
          possibleLots.push(lotConstraintsHash[i3][CONSTRAINTS_LOT_HEADING])
          print lotConstraintsHash[i3][CONSTRAINTS_LOT_HEADING] + " | "
          i3 = i3 + 1
        end
      else
        i3 = i3 + 1
      end
    end
    predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)  # go to predictBestLot method to predict the best lot for parking
    return 0
  end
end


=begin -------------------------------------------------------------------------------------------
//  Method: fridayCalculation()
//    Parameters:     lotConstraintsHash, historicParkingHash, userPermission, userDate, timeOfDay,
//                    dayOfWeek
//    Pre-condition:  The user entered a Friday dayOfWeek input and a timeOfDay input
//    Post-condition: Based on user input, a new function will be invoked that will calculate
//                    legal lots for the user to park in based on lot time constraints.
//------------------------------------------------------------------------------------------------
=end

def fridayCalculation(lotConstraintsHash, historicParkingHash, userPermission, userDate, timeOfDay, dayOfWeek)
  possibleLots = Array.new
  puts "Based on your permissions and parking time info, you can park in the following lots:\n"
  if timeOfDay >= Time.parse("5:00 AM") && timeOfDay <= Time.parse(HEADING2_TIME2)    # Check if users time is between 5:00AM-4:00PM for Friday
    i1 = 0                        # simple dummy/counter variable (used for indexing)
    while i1 < lotConstraintsHash.count()     # create loop that will run for length of lotConstraintsHash (will run for all parking lots in lotConstraintsHash)
      if (lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING2].nil?)   # if no user permissions exists for a particular lot, that lot will be skipped
        i1 = i1 +  1              # increment dummy/counter variable to skip lots with empty permissions

        # if user permissions for a particular lot is not empty, then permissions will be checked to see if they match with users member title or matches with "All"
      elsif (lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING2].upcase.include? userPermission or lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING2].include? "All")
        if (lotConstraintsHash[i1][CONSTRAINTS_LOTS_CLOSED].include? userDate)   # if lot will be closed on same date as users date, don't include that lot in the results
          i1 = i1 + 1     # increment dummy counter so that closed lot won't be included in result
        else
          possibleLots.push(lotConstraintsHash[i1][CONSTRAINTS_LOT_HEADING])    # Add the lots that user can park in into the possibleLots array
          print lotConstraintsHash[i1][CONSTRAINTS_LOT_HEADING] + " | "         # Print out the lots that user can park in
          i1 = i1 + 1
        end
      else
        i1 = i1 + 1
      end
    end
    predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)  # go to predictBestLot method to predict the best lot for parking
    return 0

  else timeOfDay >= Time.parse(HEADING4_TIME1) && timeOfDay <= Time.parse(HEADING4_TIME2)      # Only other time to check will be the left over time for Friday. See comments above for method
    i1 = 0
    while i1 < lotConstraintsHash.count()
      if (lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING4].nil?)
        i1 = i1 +  1
      elsif (lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING4].upcase.include? userPermission or lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING4].include? "All")
        if (lotConstraintsHash[i1][CONSTRAINTS_LOTS_CLOSED].include? userDate)
          i1 = i1 + 1
        else
          possibleLots.push(lotConstraintsHash[i1][CONSTRAINTS_LOT_HEADING])
          print lotConstraintsHash[i1][CONSTRAINTS_LOT_HEADING] + " | "
          i1 = i1 + 1
        end
      else
        i1 = i1 + 1
      end
    end
    predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)  # go to predictBestLot method to predict the best lot for parking
    return 0
  end
end


=begin -------------------------------------------------------------------------------------------
//  Method: weekEndCalculation()
//    Parameters:     lotConstraintsHash, historicParkingHash, userPermission, userDate, timeOfDay,
//                    dayOfWeek
//    Pre-condition:  The user entered a Saturday-Sunday dayOfWeek input and a timeOfDay input
//    Post-condition: Based on user input, a new function will be invoked that will calculate
//                    legal lots for the user to park in based on lot time constraints.
//------------------------------------------------------------------------------------------------
=end

def weekEndCalculation(lotConstraintsHash, historicParkingHash, userPermission, userDate, timeOfDay, dayOfWeek)
  possibleLots = Array.new
  puts "Based on your permissions and parking time info, you can park in the following lots:\n"
  if timeOfDay >= Time.parse(HEADING4_TIME1) && timeOfDay <= Time.parse(HEADING4_TIME2)    # Check if users time is between 4:00-9:00PM for Saturday - Sunday
    i1 = 0                        # simple dummy/counter variable (used for indexing)
    while i1 < lotConstraintsHash.count()     # create loop that will run for length of lotConstraintsHash (will run for all parking lots in lotConstraintsHash)
      if (lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING4].nil?)   # if no user permissions exists for a particular lot, that lot will be skipped
        i1 = i1 +  1              # increment dummy/counter variable to skip lots with empty permissions

        # if user permissions for a particular lot is not empty, then permissions will be checked to see if they match with users member title or matches with "All"
      elsif (lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING4].upcase.include? userPermission or lotConstraintsHash[i1][CONSTRAINTS_PERMISSIONS_HEADING4].include? "All")
        if (lotConstraintsHash[i1][CONSTRAINTS_LOTS_CLOSED].include? userDate)   # if lot will be closed on same date as users date, don't include that lot in the results
          i1 = i1 + 1     # increment dummy counter so that closed lot won't be included in result
        else
          possibleLots.push(lotConstraintsHash[i1][CONSTRAINTS_LOT_HEADING])    # Add the lots that user can park in into the possibleLots array
          print lotConstraintsHash[i1][CONSTRAINTS_LOT_HEADING] + " | "         # Print out the lots that user can park in
          i1 = i1 + 1
        end
      else
        i1 = i1 + 1
      end
    end
    predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)  # go to predictBestLot method to predict the best lot for parking
    return 0
  else
    puts "No permissions are available for that time.\nDo you want to restart the program? Enter 'yes' or 'no' "   # No permissions exist for any other times
    userRestart = gets.chomp
    userRestart.upcase!
    if userRestart == "Y" or userRestart == "YES"             # User can restart program if they'd like
      system "clear" or system "cls"
      puts "OK! The program will restart now!\n\n\n\n"
      csvLocation()                 # Go to csvLocation to allow for new file input
      return 0
    else                  # Otherwise, end the program
      puts "Thank you for using the program! Goodbye."
      return 0
    end
    return 0
  end
end


=begin -------------------------------------------------------------------------------------------
//  Method: possibleParkingLots()
//    Parameters:     lotConstraintsHash, historicParkingHash, userPermission
//    Pre-condition:  The user knows the day of the week, day of the month, and time that they
//                    park on campus. The user entered an appropriate member title.
//    Post-condition: Based on user input, a new function will be invoked that will calculate
//                    legal lots for the user to park in.
//------------------------------------------------------------------------------------------------
=end

def possibleParkingLots(lotConstraintsHash, historicParkingHash, userPermission)   # Method to determine lots that user is allowed to park in based off of user's permission and specific time/day of week/date
  puts "\n\nPlease make sure you input your answers for this section according to the instructed format. If you see this message multiple\ntimes, it means that you inputted something incorrectly."
  puts "You will then need to reenter all of your information for this section. "
  puts "\n\nWhat day of the week do you plan on parking? Enter M T W Th F Sa Su:"
  dayOfWeek = gets.chomp               # taking in user's day of week input, ensuring that it matches to days of week as defined in program
  dayOfWeekCopy = dayOfWeek         # converting user day of week to avoid case sensitive issue
  dayOfWeekCopy.upcase!
  if (dayOfWeekCopy == "M" or dayOfWeekCopy == "T" or dayOfWeekCopy == "W" or dayOfWeekCopy == "TH" or dayOfWeekCopy == "F" or dayOfWeekCopy == "SA" or dayOfWeekCopy == "SU")
    puts "\nWhat time do you plan on parking? Enter time as HH:MM AM or HH:MM PM"
    time = gets.chomp                  # taking in user's time input (can only do this if user entered day of week as defined in program
    begin                              # create a begin-end block that will  check time and utilize rescue (see below)
      timeOfDay = Time.parse(time)     # utilize Time.parse to convert user's string input
    rescue ArgumentError               # if Time.parse raises an argument error (aka user's input does not contain time information when parsed), the method will be repeated
      puts "No time data was found for your input. Please retype your information\n"
      possibleParkingLots(lotConstraintsHash, historicParkingHash, userPermission)
      return 0                         # return 0 to avoid complications if this method is repeated/rerun
    end                                # end the begin-end block, since the time input will be checked here in its own context
  else
    puts "Enter a proper day of the week please"
    possibleParkingLots(lotConstraintsHash, historicParkingHash, userPermission)  # if user did not enter appropiate date as defined by method, method will be restarted
    return 0                          # return 0 to avoid complications if this method is rerun
  end
  puts "\nPlease enter the date of the month that you will be parking\n"
  userDate = gets.chomp
  case dayOfWeekCopy
  when "M", "T", "W", "TH"      # Monday-Thursday input will transfer to a weekDayCalculation
    weekDayCalculation(lotConstraintsHash, historicParkingHash, userPermission, userDate, timeOfDay, dayOfWeek)
    return 0
  when "F"                     # Friday will transfer to fridayCalculation
    fridayCalculation(lotConstraintsHash, historicParkingHash, userPermission, userDate, timeOfDay, dayOfWeek)
    return 0
  when "SA", "SU"             # Saturday-Sunday will transfer to a weekEndCalculation
    weekEndCalculation(lotConstraintsHash, historicParkingHash, userPermission, userDate, timeOfDay, dayOfWeek)
    return 0
  else                # No appropiate day of the week will result in method restart
    puts "You did not enter proper data. Please reenter your information\n"   # Printing out statement in case of error
    possibleParkingLots(lotConstraintsHash, historicParkingHash, userPermission)    # Rerun this method if error is found
    return 0                    # return 0 to avoid complications if this method is rerun
  end
end


=begin -------------------------------------------------------------------------------------------
//  Method: memberTitle()
//    Parameters:     lotConstraintsHash, historicParkingHash
//    Pre-condition:  The user's data files are correctly mapped to a hash table in such a way as
//                    to allow for indexing. The user knows what type of TCNJ member they are.
//    Post-condition: The user will have posted an acceptable member title;
//                    possibleParkingLots method will be invoked.
//------------------------------------------------------------------------------------------------
=end

def memberTitle(lotConstraintsHash, historicParkingHash)      # Method to allow user to input their member title in TCNJ
  puts "What type of TCNJ member are you? You may enter the following: \n"
  puts "UC, GC, RA, RS, Faculty/Staff, Visitor\n"
  userPermission = gets.chomp        # Take in user input, make sure it matches one of the user permission titles present in constraints file
  userPermission.upcase!
  if (userPermission == "UC" or userPermission == "GC" or userPermission == "RA" or userPermission == "RS" or userPermission == "FACULTY/STAFF" or userPermission == "VISITOR")
    possibleParkingLots(lotConstraintsHash, historicParkingHash, userPermission)  # If userPermission matches with permissions in lotConstraints, proceed to possibleParkingLots method
    return 0
  else
    puts "You did not enter a proper member position. Please try again.\n\n"
    memberTitle(lotConstraintsHash, historicParkingHash)      # If user input does not match with member titles in constraints csv, reprompt for input
    return 0                        # return 0 to avoid complications if this method is rerun
  end
  return 0
end


=begin -------------------------------------------------------------------------------------------
//  Method: mapToHash()
//    Parameters:     lotConstraints, historicParking
//    Pre-condition:  User's two CSV files are confirmed to exist on the machine. The files contain
//                    data as formatted in the sample files (including same column titles).
//    Post-condition: The two files will be read by the program and mapped to a hash table.
//                    The headings of the CSV files will be used as keys for the table. The
//                    memberTitle method will be invoked
//------------------------------------------------------------------------------------------------
=end

def mapToHash(lotConstraints, historicParking)      # Method to read in CSV files and map that to hash tables
  lotConstraintsData = CSV.read(lotConstraints, {   # lotConstraintsData variable that reads CSV files. Headers exist so headers option is enabled. All data converted if possible
    headers: true, converters: :all
  })

  lotConstraintsHash = lotConstraintsData.map { |row|   # data is then mapped to a hash table (done row by row)
    row.to_hash
  }
  historicParkingData = CSV.read(historicParking, {     # same procedure as above, but for historic parking CSV file. Since file is most likely very very large,
    # this operation will take some time
    headers: true, converters: :all
  })
  historicParkingHash = historicParkingData.map { |row|
    row.to_hash
  }
  puts "\nTransfer Complete! Just a couple more questions.\n\n"       # once transfer is complete, prompt user for rest of questions
  memberTitle(lotConstraintsHash, historicParkingHash)                # go to memberTitle method to continue program
  return 0
end


=begin -------------------------------------------------------------------------------------------
//  Method: csvLocation()
//    Parameters:     None
//    Pre-condition:  User should have two CSV files present on computer (lot constraints
//                    and historical data), and should know the working directories of said files
//    Post-condition: The existence of the files provided by the user are valid and present.
//                    The mapToHash method will be invoked
//------------------------------------------------------------------------------------------------
=end

def csvLocation                                   # Method to allow user to input CSV file locations
  puts "You should have two CSV files that contain data regarding the TCNJ parking lots."
  puts "You will have to enter the names of the files. If the file is located in the same spot as this program, then just type in the filename. "
  puts "If the file is in a different directory, please copy and paste the directory instead. Please note: your input is case sensitive here. "
  puts "\nHere are two examples of what you could type in, depending on where your file is located. Be sure to replace '<filename>' with whatever your file is called\n"
  puts "Ex: <filename.csv> or <C:/Program/Files/filename.csv> "
  puts "Please enter the filename or filename directory of your lot constraints file: "

  lotConstraintsFile = gets.chomp                 # Take in user input
  isDirectory = File.exist?(lotConstraintsFile)   # Check for file existence in user's specified directory
  if isDirectory == false                         # If file does not exist, require user to reenter input
    puts "Sorry, the file was not found. The instructions will be reprinted on the screen so you can try again.\n\n"
    csvLocation                                   # Rerun this method
    return 0                                      # Return 0 to avoid complications if this method is run multiple times
  end

  puts "\nFile Found! You should also have another file relating to the parking lot history"
  puts "Please enter that filename or directory here: "

  historicParkingFile = gets.chomp          # Take in user's input again, check if CSV file exists (this will only occur if user's first directory exists)
  isDirectory = File.exist?(historicParkingFile)
  if isDirectory == false
    puts "\nSorry, the file was not found. You will need to retype both filenames."
    puts "Don't worry, the instructions will be reprinted on the screen\n\n"
    csvLocation                             # Rerun this method if second directory is false
    return 0                                # return 0 to avoid complications when rerunning this method
  else
    puts"\nFile Found! The program will now interpret this data into its database"      # Notify user that data will be mapped to hashes
    puts "This may take a few seconds. One moment please..."              # Mapping may take a while due to historical file being very large
    mapToHash(lotConstraintsFile, historicParkingFile)    # Go to mapToHash so that CSV files can be read and mapped to hashes
    return 0
  end
end


=begin -------------------------------------------------------------------------------------------
//  Method: introduction()
//    Parameters:     None
//    Pre-condition:  The program should start, with no variables initialized
//                    and no global variables present
//    Post-condition: the csvLocation() method will be invoked
//------------------------------------------------------------------------------------------------
=end

def introduction          # Method that serves as a simple introduction to output to user
  puts "Hello! Welcome to the TCNJ Parking Spaces Application.\n"
  puts "This program will suggest to you where to park based on the data you input.\n"
  puts "Simply follow the prompts provided on the screen to get started.\n\n"
  csvLocation()           # Go to csvLocation method, so user can input files
  return 0
end

introduction()            # Program begins by running introduction method 