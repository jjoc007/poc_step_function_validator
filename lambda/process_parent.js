exports.handler = async event => {
  const action = event.action;
  console.log(`The Action is: ${action}`);

  if (action === 'create_process_parent') {
    const number =  Math.floor(Math.random() * 100000000);
    return {parent_number: number, status: 'created'}
  } else if (action === 'destroy_process_parent'){
    const parent_number = event.parent_number;
    console.log(`Parent Number: ${parent_number} Destroyed`);
  } else {
    console.log(`The action is not valid: ${action}`);
    return {action: action, valid: false}
  }
};
