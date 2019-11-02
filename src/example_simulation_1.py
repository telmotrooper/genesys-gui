from io import BytesIO
from stdout_redirector import stdout_redirector
from user_interface import UserInterface
import libgenesys

def run_simulation(handler):
  ui = UserInterface(None)
  component_counter = 0  
  f = BytesIO()

  with stdout_redirector(f):
    # Instantiate a simulator
    simulator = libgenesys.Simulator()

    libgenesys.PyGenesysApplication().insertFakePluginsByHand(simulator)

    # Create an empty model
    model = libgenesys.Model(simulator)

    # Should "handle traces and simulation events to output them"
    tm = model.getTraceManager()
    libgenesys.PyGenesysApplication().setDefaultTraceHandlers(tm);

    # Get easy access to classes used to insert components and elements into a model
    components = model.getComponentManager()
    elements = model.getElementManager()

    # Set the trace level of the simulation
    simulator.getTraceManager().setTraceLevel(libgenesys.TraceLevel.blockArrival)

    # Create a SourceModelElement of type EntityType, which will be used by a ModelComponent later
    entityType1 = libgenesys.EntityType(elements, "Type_of_Representative_Entity")
    elements.insert(entityType1.getTypename(), entityType1)

    # Create a ModelComponent of type Create, used to insert entities into the model
    create1 = libgenesys.Create(model)
    create1.setEntityType(entityType1)
    create1.setTimeBetweenCreationsExpression("1.5")
    components.insert(create1)

    # Create a ModelComponent of type Delay, used to represent a time delay
    delay1 = libgenesys.Delay(model)  # By default delay takes 1 second
    components.insert(delay1)

    # Create a SinkModelComponent of type Dispose, used to remove entities from the model
    dispose1 = libgenesys.Dispose(model)
    components.insert(dispose1)

    # Connect model components to create a "workflow". Should always start from
    # a SourceModelComponent and end at a SinkModelComponent (it will be checked)
    create1.getNextComponents().insert(delay1)
    delay1.getNextComponents().insert(dispose1)

    # Insert the model into the simulator 
    simulator.getModelManager().insert(model)

    # Insert components into GUI list
    insert_into_list(create1)
    insert_into_list(delay1)
    insert_into_list(dispose1)

    # If the model is ok then save it into a text file 
    # if model.checkModel():
    #     model.saveModel("src/models/example_1.txt") # Assuming you're running from root folder
        # If the model is saved into a file, it can be just loaded instead of built

    # Execute the simulation util completed and show the report
    model.getSimulation().startSimulation()

  # Print to GUI stuff that was just executed
  handler.print_to_log(f.getvalue().decode('utf-8'))

def insert_into_list(component):
  ui = UserInterface(None)
  text = component.show().split(",")

  nextText = "="

  if type(component) != libgenesys.Dispose:
    nextComponent = component.getNextComponents().front()
    nextText = nextComponent.show().split(",")

  ui.list_store.append([
    text[1].split('"')[1],
    component.__class__.__name__,
    text[0].split("=")[1],
    nextText[0].split("=")[1]
  ])
