class JobsController < ApplicationController

  def job_answer_sets
    # data = JSON.parse(params[:json_form])
    file = File.open Rails.root.join('public', 'form.json')
    data = JSON.load file
    required_properties = setRequired( data )
    answer_set = initializeAnswerSet(required_properties)
    answer_set.concat(setConditions(data,answer_set))
    puts JSON.pretty_generate(answer_set)
    # puts answer_set.length
  end

  def setRequired(data)
    required_properties = []
    data["required"].each do | property |
      property_object = {}
      if data["properties"][property]["enum"] != nil
        property_object[property] = data["properties"][property]["enum"]
      end
      required_properties.push(property_object)
    end
    required_properties
  end

  def initializeAnswerSet(required_set)
    initial_answer_set = []
    cloned_answer_set = []
    required_set.each_with_index do | property, index |
      if index == 0
        primary_answers = primaryProperties(property)
        initial_answer_set.concat(primary_answers)
      else
        cloned_answers = secondaryProperties(property,initial_answer_set)
        cloned_answer_set.concat(cloned_answers)
      end
    end  
    cloned_answer_set
  end

  def primaryProperties(property)
    properties = []
    property.each do | property_name, val_array|
      val_array.each do | enum_val |
        property_object = {}
        property_object[property_name] = enum_val
        properties.push(property_object)
      end
    end
    properties
  end

  def secondaryProperties(property,initial_answer_set)
    cloned_answers = []
    property.each do | property_name, val_array|
      initial_answer_set.each do | answerSet |
        val_array.each do | enum_val |
          cloned_property = answerSet.clone
          cloned_property[property_name] = enum_val
          cloned_answers.push(cloned_property)
        end
      end
    end
    cloned_answers
  end

  def setConditions(data, answer_set)
    additional_answers = []
    data["allOf"].each do | condition |
      answer_set.each do | answer |
        # Check all conditions 
        condition_check_array = []
        condition["if"]["properties"].each do | property_name, property_val |
          if answer[property_name] == property_val["const"] 
            condition_check_array.push(true)
          end
        end
        if condition_check_array.length == condition["if"]["properties"].length
          conditional_answers = getConditionAnswers(condition,data,answer)
          additional_answers.concat(conditional_answers)
        end
      end
    end
    additional_answers
  end

  def getConditionAnswers(condition,data,answer)
    cloned_conditional_answers = []
    # Do the then
    if condition["then"]["required"] != nil
        condition["then"]["required"].each do | property |
          if data["properties"][property]["type"] == "boolean"
            answer[property] = true
            cloned_answer = answer.clone
            cloned_answer[property] = false
            cloned_conditional_answers.push(cloned_answer)
          end
        end
      end
      cloned_conditional_answers
    end

end