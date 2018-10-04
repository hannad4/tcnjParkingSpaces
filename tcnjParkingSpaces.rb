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
// Last modified on: 10/4/2018
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

require 'pathname'    #Require pathname to check if user's file exists on the computer or not. 
require 'csv'         #Require csv in order to read CSV files and map them to a hash table
require 'time'        #Require time in order to convert user input into time 

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
      i["Parking Lot"] == possibleLots[variable] and Date.strptime(i["Date"], '%m/%d/%Y') == userDate and Time.parse(i["Time"]).hour == timeOfDay.hour }
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
    puts "No lots are predicted because no permissions are found for your member title at the time you entered.\nThank you for using the program, goodbye!"
    return 0
  end
  puts historicalLotData[finalArray.index(finalArray.max)]["Parking Lot"]     # Print the lot with the highest number of open spots
  print "Estimated number of spots available: "
  puts finalArray.max                                       # Print number of spots available
  puts "\nThank you for using this program. Goodbye!" 
  return 0                                                # Return 0 to terminate program 
end

=begin -------------------------------------------------------------------------------------------
//  Method: possibleParkingLots()
//    Parameters:     lotConstraintsHash, historicParkingHash, userPermission
//    Pre-condition:  The user knows the day of the week, day of the month, and time that they
//                    park on campus. The user entered an appropriate member title, properly
//                    formatted time, and date that can be converted to match a date in the
//                    historical file. 
//    Post-condition: A list of 'legal' lots for the user to park in is created through array 
//                    possibleLots. These lots are also printed on the screen as they are being
//                    added to the array. The predictBestLot method will be invoked
//------------------------------------------------------------------------------------------------
=end 

def possibleParkingLots(lotConstraintsHash, historicParkingHash, userPermission)   # Method to determine lots that user is allowed to park in based off of user's permission and specific time/day of week/date
  puts "\n\nPlease make sure you input your answers for this section according to the instructed format. If you see this message multiple\ntimes, it means that you inputted something incorrectly."
  puts "You will then need to reenter all of your information for this section. "
  puts "\n\nWhat day of the week do you plan on parking? Enter M T W Th F Sa Su:"
  
  dayOfWeek = gets.chomp               # taking in user's day of week input, ensuring that it matches to days of week as defined in program 
  if (dayOfWeek == "M" or dayOfWeek == "T" or dayOfWeek == "W" or dayOfWeek == "Th" or dayOfWeek == "F" or dayOfWeek == "Sa" or dayOfWeek == "Su")
    puts "\nWhat time do you plan on parking? Enter time as HH:MM AM or HH:MM PM"
    time = gets.chomp                  # taking in user's time input (can only do this if user entered day of week as defined in program
    begin                              # create a begin-end block that will  check time and utilize rescue (see below)
      timeOfDay = Time.parse(time)     # utilize Time.parse to convert user's string input 
    rescue ArgumentError               # if Time.parse raises an argument error (aka user's input does not contain time information when parsed), the method will be repeated 
      possibleParkingLots(lotConstraintsHash, historicParkingHash, userPermission)
      return 0                         # return 0 to avoid complications if this method is repeated/rerun
    end                                # end the begin-end block, since the time input will be checked here in its own context  
  else
    puts "Enter a proper day of the week please"
    possibleParkingLots(lotConstraintsHash, historicParkingHash, userPermission)  # if user did not enter appropiate date as defined by method, method will be restarted
    return 0                          # return 0 to avoid complications if this method is rerun
  end
  
  puts "\nEnter the day of the month that you will be parking. Examples: 10/1/2018, 8/31/2018"
  userDate = gets.chomp               # take in users date
  puts "Based on the fact that you're a #{userPermission} member, then you can park in the following lots"
  puts "Note: No data printed on screen means no permissions data was found for #{userPermission} members for the time of #{time.upcase} on #{userDate}."
  possibleLots = Array.new            # creating new array (legal parking lots for user will be appended here)
  
  case dayOfWeek                    # create a case statement that checks through the day of the week 
  when "M", "T", "W", "Th"          # Days Monday-Thursday have same permissions for same hours, so check these times under the same case
    if timeOfDay >= Time.parse("02:30 AM") && timeOfDay <= Time.parse("4:59 AM")    # Check if users time is between 2:30-5:00AM for Monday - Thursday 
      i1 = 0                        # simple dummy/counter variable (used for indexing) 
      while i1 < lotConstraintsHash.count()     # create loop that will run for length of lotConstraintsHash (will run for all parking lots in lotConstraintsHash)
        if (lotConstraintsHash[i1]["Permissions Mon through Thurs 2:30am to 5:00 am"].nil?)   # if no user permissions exists for a particular lot, that lot will be skipped
          i1 = i1 +  1              # increment dummy/counter variable to skip lots with empty permissions
          
        # if user permissions for a particular lot is not empty, then permissions will be checked to see if they match with users member title or matches with "All"
        elsif (lotConstraintsHash[i1]["Permissions Mon through Thurs 2:30am to 5:00 am"].include? userPermission or lotConstraintsHash[i1]["Permissions Mon through Thurs 2:30am to 5:00 am"].include? "All")
          if (lotConstraintsHash[i1]["Dates Lot Will be Closed"].include? userDate)   # if lot will be closed on same date as users date, don't include that lot in the results
            i1 = i1 + 1     # increment dummy counter so that closed lot won't be included in result
          else
            possibleLots.push(lotConstraintsHash[i1]["Parking Lot"])    # Add the lots that user can park in into the possibleLots array
            print lotConstraintsHash[i1]["Parking Lot"] + " | "         # Print out the lots that user can park in 
            i1 = i1 + 1       
          end 
        else
          i1 = i1 + 1
        end
      end
      predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)  # go to predictBestLot method to predict the best lot for parking
      return 0
      
    elsif timeOfDay >= Time.parse("5:00 AM") && timeOfDay <= Time.parse("3:59 PM")    # similar check to above, see comments
      i2 = 0
      while i2 < lotConstraintsHash.count()
        if (lotConstraintsHash[i2]["Permissions Mon through Fri 5:00am to 4:00pm"].nil?)
          i2 = i2 +  1
        elsif (lotConstraintsHash[i2]["Permissions Mon through Fri 5:00am to 4:00pm"].include? userPermission or lotConstraintsHash[i2]["Permissions Mon through Fri 5:00am to 4:00pm"].include? "All")      
          if (lotConstraintsHash[i2]["Dates Lot Will be Closed"].include? userDate)
            i2 = i2 + 1
          else
            possibleLots.push(lotConstraintsHash[i2]["Parking Lot"])
            print lotConstraintsHash[i2]["Parking Lot"] + " | "
            i2 = i2 + 1
          end
        else
          i2 = i2 + 1
        end
      end
      predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)
      return 0
   
    else      # Only other time to check will be the left over time for Monday - Thursday. See comments above for method
      i3 = 0
      while i3 < lotConstraintsHash.count()
        if (lotConstraintsHash[i3]["Permissions Mon through Thurs 4pm to 2:30am"].nil?)
          i3 = i3 +  1
        elsif (lotConstraintsHash[i3]["Permissions Mon through Thurs 4pm to 2:30am"].include? userPermission or lotConstraintsHash[i3]["Permissions Mon through Thurs 4pm to 2:30am"].include? "All")
          if (lotConstraintsHash[i3]["Dates Lot Will be Closed"].include? userDate)
            i3 = i3 + 1
          else
            possibleLots.push(lotConstraintsHash[i3]["Parking Lot"])
            print lotConstraintsHash[i3]["Parking Lot"] + " | "
            i3 = i3 + 1
          end
        else
          i3 = i3 + 1
        end
      end
      predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)
      return 0     
    end

  when "F"      # Friday, Saturday, Sunday have different time permissions
    if timeOfDay >= Time.parse("5:00 AM") && timeOfDay <= Time.parse("3:59 PM")       # Checking for Friday-specific time permission here. See comments above for further explanation
      i4 = 0
      while i4 < lotConstraintsHash.count()
        if (lotConstraintsHash[i4]["Permissions Mon through Fri 5:00am to 4:00pm"].nil?)
          i4 = i4 + 1
        elsif (lotConstraintsHash[i4]["Permissions Mon through Fri 5:00am to 4:00pm"].include? userPermission or lotConstraintsHash[i4]["Permissions Mon through Fri 5:00am to 4:00pm"].include? "All")
          if (lotConstraintsHash[i4]["Dates Lot Will be Closed"].include? userDate)
            i4 = i4 + 1
          else
            possibleLots.push(lotConstraintsHash[i4]["Parking Lot"])
            print lotConstraintsHash[i4]["Parking Lot"] + " | "
            i4 = i4 + 1
          end
        else
          i4 = i4 + 1
        end
      end
      predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)
      
    else timeOfDay >= Time.parse("4:00 PM") && timeOfDay <= Time.parse("8:59 PM")     # Checking for other time
        i5 = 0
        while i5 < lotConstraintsHash.count()
          if (lotConstraintsHash[i5]["Permissions Fri through Sun 4:00pm to 9:00pm"].nil?)
            i5 = i5 +  1
          elsif (lotConstraintsHash[i5]["Permissions Fri through Sun 4:00pm to 9:00pm"].include? userPermission or lotConstraintsHash[i5]["Permissions Fri through Sun 4:00pm to 9:00pm"].include? "All")
            if (lotConstraintsHash[i5]["Dates Lot Will be Closed"].include? userDate)
              i5 = i5 + 1
            else
              possibleLots.push(lotConstraintsHash[i5]["Parking Lot"])
              print lotConstraintsHash[i5]["Parking Lot"] + " | "
              i5 = i5 + 1
            end
          else
          i5 = i5 + 1
          end
        end 
        predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay) 
    end
        
  when "Sa", "Su"           # Saturday and Sunday have the same permissions for same time slots. Checking that permission here. 
    if timeOfDay >= Time.parse("4:00 PM") && timeOfDay <= Time.parse("8:59 PM")
      i6 = 0
      while i6 < lotConstraintsHash.count()
        if (lotConstraintsHash[i6]["Permissions Fri through Sun 4:00pm to 9:00pm"].nil?)
          i6 = i6 +  1
        elsif (lotConstraintsHash[i6]["Permissions Fri through Sun 4:00pm to 9:00pm"].include? userPermission or lotConstraintsHash[i6]["Permissions Fri through Sun 4:00pm to 9:00pm"].include? "All")
          if (lotConstraintsHash[i6]["Dates Lot Will be Closed"].include? userDate)
            i6 = i6 + 1
          else
            possibleLots.push(lotConstraintsHash[i6]["Parking Lot"])
            print lotConstraintsHash[i6]["Parking Lot"] + " | "
            i6 = i6 + 1
          end
        else
          i6 = i6 + 1
        end
      end
      predictBestLot(lotConstraintsHash, historicParkingHash, possibleLots, userDate, timeOfDay)
      return 0
    end

  else
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
  if (userPermission == "UC" or userPermission == "GC" or userPermission == "RA" or userPermission == "RS" or userPermission == "Faculty/Staff" or userPermission == "Visitor")
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
  puts "If the file is in a different directory, please copy and paste the directory instead "
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
